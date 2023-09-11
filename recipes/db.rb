domain_name= node['hopsworks']['domain_name']
domains_dir = node['hopsworks']['domains_dir']

# This is set correctly in hopsworks::install by the chef-glassfish recipe. As each recipe has it's own
# instance of chef we need to re-set it here.
# If you set it in the attributes it will break glassfish installation.
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
theDomain="#{domains_dir}/#{domain_name}"

public_ip=my_public_ip()
realmname = "kthfsrealm"
deployment_group = "hopsworks-dg"

exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'create_hopsworks_db' do
  user "root"
  code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS #{node['hopsworks']['db']} CHARACTER SET latin1\"
      #{exec} -e \"CREATE USER IF NOT EXISTS \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\' IDENTIFIED BY \'#{node['hopsworks']['mysql']['password']}\';\"
    EOF
end

timerTable = "ejbtimer_mysql.sql"
timerTablePath = "#{Chef::Config['file_cache_path']}/#{timerTable}"

# Need to delete the sql file so that the create_timers action is triggered
file timerTablePath do
  action :delete
  ignore_failure true
end

hopsworks_grants "timers_tables" do
  tables_path  "#{timerTablePath}"
  action :nothing
end

template timerTablePath do
  source File.basename("#{timerTablePath}") + ".erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
  notifies :create_timers, 'hopsworks_grants[timers_tables]', :immediately
end

hops_rpc_tls_val = "false"
if node['hops']['tls']['enabled'].eql? "true"
  hops_rpc_tls_val = "true"
end

condaRepo = 'defaults'
if node['conda']['channels']['default_mirrors'].empty? == false
   repos = node['conda']['channels']['default_mirrors'].split(/\s*,\s*/)
   condaRepo = repos[0]
end

# hops-util-py only works for localhost installations if you disable TLS hostname validations
if node['install']['localhost'].eql? "true"
  node.override['hopsworks']['requests_verify'] = "false"
end

versions = node['hopsworks']['versions'].split(/\s*,\s*/)
target_version = node['hopsworks']['version'].sub("-SNAPSHOT", "")
# Ignore patch versions starting from version 3.0.0
if Gem::Version.new(target_version) >= Gem::Version.new('3.0.0')
  target_version_ignore_patch_arr = target_version.split(".")
  target_version_ignore_patch_arr[2] = "0"
  target_version = target_version_ignore_patch_arr.join(".")
end
versions.push(target_version)
current_version = node['hopsworks']['current_version']

caConf = {}
rootConf = {}
if !node['hopsworks']['pki']['root']['name'].empty?
  rootConf[:x509Name] = node['hopsworks']['pki']['root']['name']
  rootConf[:validityDuration] = node['hopsworks']['pki']['root']['duration']
end

intermediateConf = {}
if !node['hopsworks']['pki']['intermediate']['name'].empty?
  intermediateConf[:x509Name] = node['hopsworks']['pki']['intermediate']['name']
  intermediateConf[:validityDuration] = node['hopsworks']['pki']['intermediate']['duration']
end

if !node['hopsworks']['pki']['intermediate']['extra_san_for_username'].empty?
  intermediateConf[:extraUsernameSAN] = JSON.parse(node['hopsworks']['pki']['intermediate']['extra_san_for_username'])
end

kubernetesConf = {}
if !node['hopsworks']['pki']['kubernetes']['name'].empty?
  kubernetesConf[:x509Name] = node['hopsworks']['pki']['kubernetes']['name']
  kubernetesConf[:validityDuration] = node['hopsworks']['pki']['kubernetes']['duration']
end

if node['install']['kubernetes'].casecmp?('true') && node['install']['managed_kubernetes'].casecmp?('false')
  kubernetesConf[:subjectAlternativeName] = {
    :dns => [node['fqdn'], node['kube-hops']['cluster_name'],
              "#{node['kube-hops']['cluster_name']}.default",
              "#{node['kube-hops']['cluster_name']}.default.svc",
              "#{node['kube-hops']['cluster_name']}.default.svc.cluster",
              "#{node['kube-hops']['cluster_name']}.default.svc.cluster.local",
              "*.hops-system.svc"
            ],
    :ip => [node['kube-hops']['cidr'].split('/')[0].reverse.sub('0', '1').reverse,
              private_recipe_ip('kube-hops', 'master'),
              "127.0.0.1",
              node['kube-hops']['dns_ip'],
              "10.96.0.1"]
  }
end

caConf[:rootCA] = rootConf
caConf[:intermediateCA] = intermediateConf
caConf[:kubernetesCA] = kubernetesConf


# Usernames configuration
usernamesConfiguration = {}
usernamesConfiguration[:glassfish] = node['hopsworks']['user']
usernamesConfiguration[:hdfs] = node['hops']['hdfs']['user']
usernamesConfiguration[:rmyarn] = node['hops']['rm']['user']
usernamesConfiguration[:yarn] = node['hops']['yarn']['user']
usernamesConfiguration[:hive] = node['hive2']['user']
usernamesConfiguration[:livy] = node['livy']['user']
usernamesConfiguration[:flink] = node['flink']['user']
usernamesConfiguration[:consul] = node['consul']['user']
usernamesConfiguration[:hopsmon] = node['hopsmonitor']['user']
usernamesConfiguration[:zookeeper] = node['kzookeeper']['user']
usernamesConfiguration[:onlinefs] = node['onlinefs']['user']
usernamesConfiguration[:elastic] = node['elastic']['user']
usernamesConfiguration[:kagent] = node['kagent']['user']
usernamesConfiguration[:mysql] = node['ndb']['user']
usernamesConfiguration[:airflow] = node['airflow']['user']
if node.attribute?('flyingduck') && node['flyingduck'].attribute?('user')
  usernamesConfiguration[:flyingduck] = node['flyingduck']['user']
end

if current_version.eql?("")

  # Make sure the database is actually empty. Otherwise raise an error
  ruby_block "check_db_empty" do
    block do
      raise "You are trying to initialize the database, but the database is not empty. Either there is a failed migration, or you forgot to set the current_version attribute"
    end
    only_if "#{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks -e \"SHOW TABLES\" | grep project"
  end

  # New installation -> template the current version schema file
  cookbook_file "#{theDomain}/flyway/sql/V#{target_version}__initial_tables.sql" do
    source "sql/ddl/#{target_version}__initial_tables.sql"
    owner node['glassfish']['user']
    mode 0750
    action :create
  end
else
  # Current version can contain the patch version. However we don't have schemas for patch versions
  # Which means that the `version.index` operation below will fail. To avoid this we parse the version
  # and we replace the patch version to 0 before searching the version list.
  version_segments = Gem::Version.new(current_version).canonical_segments()
  version_segments[2] = 0
  minor_version = version_segments.join('.')

  minor_version_idx = versions.index(minor_version).to_i
  versions_length = versions.length.to_i - 1

  for i in (minor_version_idx + 1)..versions_length
    # Update, template all the dml files from the current version to the target version
    cookbook_file "#{theDomain}/flyway/sql/V#{versions[i]}__hopsworks.sql" do
      source "sql/ddl/updates/#{versions[i]}.sql"
      owner node['glassfish']['user']
      mode 0750
      action :create
    end
  end
end

unless node['install']['cloud'].strip.empty?
  node.override['hopsworks']['reserved_project_names'] = "#{node['hopsworks']['reserved_project_names']},cloud"
end

# encrypt onlinefs user password
onlinefs_salt = SecureRandom.base64(64)
encrypted_onlinefs_password = Digest::SHA256.hexdigest node['onlinefs']['hopsworks']['password'] + onlinefs_salt

# encrypt airflow user poassword
airflow_salt = SecureRandom.base64(64)
encrypted_airflow_password = Digest::SHA256.hexdigest node['airflow']['hopsworks']['password'] + airflow_salt

# Check if Kafka is to be installed 
kafka_installed = true
begin
  valid_recipe("kkafka", "default")
  Chef::Log.info "Found kafka cookbooks, will proceed to create db user for Kafka"
  kafka_installed = true
rescue
  Chef::Log.info "Kafka will not be installed, skipped creating DB user."
  kafka_installed = false
end

apparmor_enabled = is_apparmor_enabled() && node['hops']['docker']['load-hopsfsmount-apparmor-profile'].casecmp?("true")

for version in versions do
  # Template DML files
  template "#{theDomain}/flyway/dml/V#{version}__hopsworks.sql" do
    source "sql/dml/#{version}.sql.erb"
    owner node['glassfish']['user']
    mode 0750
    variables({
         :user_cert_valid_days => node['hopsworks']['cert']['user_cert_valid_days'],
         :conda_repo => condaRepo,
         :hopsworks_dir => theDomain,
         :hops_rpc_tls => hops_rpc_tls_val,
         :yarn_default_quota => node['hopsworks']['yarn_default_quota_mins'].to_i * 60,
         :java_home => node['java']['java_home'],
         :public_ip => public_ip,
         :krb_ldap_auth => node['ldap']['enabled'].to_s == "true" || node['kerberos']['enabled'].to_s == "true",
         :hops_version => node['hops']['version'],
         :onlinefs_password => encrypted_onlinefs_password,
         :onlinefs_salt => onlinefs_salt,
         :pki_ca_configuration => caConf.to_json(),
         :usernames_configuration => usernamesConfiguration.to_json(),
         :kafka_installed => kafka_installed,
         :apparmor_enabled => apparmor_enabled,
         :ha_enabled => node['hopsworks'].attribute?('das_node'),
         :airflow_salt => airflow_salt,
         :airflow_password => encrypted_airflow_password
    })
    action :create
  end

   # template all the ddl files from all versions
   cookbook_file "#{theDomain}/flyway/all/sql/V#{version}__hopsworks.sql" do
    source "sql/ddl/updates/#{version}.sql"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode 0750
    action :create
  end


  if Gem::Version.new(version) >= Gem::Version.new('2.0.0')
    cookbook_file "#{theDomain}/flyway/all/sql/V#{version}__initial_tables.sql" do
      source "sql/ddl/#{version}__initial_tables.sql"
      owner node['glassfish']['user']
      group node['glassfish']['group']
      mode 0750
      action :create
    end
  end 
  
end

bash "flyway_migrate" do
  user "root"
  cwd "#{theDomain}/flyway"
  code <<-EOF
    # Validation during migrate is very strict for our needs. If we found a bug
    # on a released branch and we fix it, next time someone upgrades to released branch+1
    # they will get a validation error because the files checksum do not match
    #{theDomain}/flyway/flyway -validateOnMigrate=false migrate
  EOF
end

# Run the DML sql script to insert the variables
for version in versions do
  bash "run_inserts_#{version}" do
    user "root"
    code <<-EOH
      #{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks < #{theDomain}/flyway/dml/V#{version}__hopsworks.sql
    EOH
  end
end

# Create the users_groups view if it doesn't exists (see HWORKS-457 for explanation)
bash "create users_groups view" do
  user "root"
  code <<-EOH
    #{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks -e "CREATE OR REPLACE VIEW users_groups AS select u.username AS username, u.password AS password, u.secret AS secret, u.email AS email,g.group_name AS group_name from ((user_group ug join users u on((u.uid = ug.uid))) join bbc_group g on((g.gid = ug.gid)));"
  EOH
end