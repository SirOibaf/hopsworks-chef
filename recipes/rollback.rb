# Copyright (C) 2014 - 2018 Logical Clocks AB. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

glassfish_deployable "undeploy_hopsworks-ear" do
  component_name "hopsworks-ear:*"
  target "server"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  keep_state true
  action :undeploy
end

glassfish_deployable "undeploy_hopsworks-war" do
  component_name "hopsworks-web:*"
  target "server"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  keep_state true
  action :undeploy
end

glassfish_deployable "undeploy_hopsworks-ca" do
  component_name "hopsworks-ca:*"
  target "server"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  keep_state true
  action :undeploy
end

bash "flyway_undo" do
  user "root"
  code <<-EOF
    set -e
    cd #{theDomain}/flyway
    #{theDomain}/flyway/flyway undo
  EOF
end

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear"
  target "server"
  url node['hopsworks']['ear_url']
  version node['hopsworks']['version']
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  action :deploy
  keep_state true
  async_replication false
  retries 1
  enabled true
end


glassfish_deployable "hopsworks" do
  component_name "hopsworks-web"
  target "server"
  url node['hopsworks']['war_url']
  version node['hopsworks']['version']
  context_root "/hopsworks"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  action :deploy
  keep_state true
  async_replication false
  retries 1
  enabled true
end

glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca"
  target "server"
  url node['hopsworks']['ca_url']
  version node['hopsworks']['version']
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure true
  action :deploy
  keep_state true
  async_replication false
  retries 1
  enabled true
end
