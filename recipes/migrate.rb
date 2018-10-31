expat_filename = File.basename(node['hopsworks']['expat'])
expat_file = "#{Chef::Config['file_cache_path']}/#{expat_filename}"

remote_file expat_file do
  source node['hopsworks']['expat']
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bash "extract" do
  user "root"
  code <<-EOH
    mkdir #{node['hopsworks']['expat_dir']} 
    tar xf #{expat_file} -C #{node['hopsworks']['expat_dir']} 
  EOH
  action :run
  not_if {::Dir.exist?(node['hopsworks']['expat_dir'])}
end

remote_file "#{node['hopsworks']['expat_dir']}/lib/mysql-connector-java.jar" do
  source node['hopsworks']['mysql_connector_url']
  owner 'root'
  group 'root'
  mode '0750'
  action :create
end

template "#{node['hopsworks']['expat_dir']}/etc/expat-site.xml" do
  source 'expat-site.xml.erb'
  owner 'root'
  mode '0750'
  action :create
  variables ({
    mysql_ip: mysql_ip
  })
end

bash 'run-expat' do
  user "root"
  environment ({'HADOOP_HOME' => node['hops']['base_dir'],
                'HOPSWORKS_EAR_HOME' => "#{node['hopsworks']['domains_dir']}/#{node['hopsworks']['domain_name']}/applications/hopsworks-ear~#{node['install']['version']}"}) 
  code <<-EOH
    #{node['hopsworks']['expat_dir']}/expat -a migrate -v #{node['install']['version']}
  EOH
  action :run
end