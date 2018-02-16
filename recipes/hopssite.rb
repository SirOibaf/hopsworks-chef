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
#
#START hopssite install scripts
directory node['hopssite']['home'] do
  owner node['glassfish']['user']
  mode 0755
  action :create
end

template "#{node['hopssite']['home']}/hs_env.sh" do
  source "hopssite/hs_env.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_install.sh" do
  source "hopssite/hs_install.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_setup.sh" do
  source "hopssite/hs_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_db_setup.sh" do
  source "hopssite/hs_db_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_create_domain2.sh" do
  source "hopssite/hs_create_domain2.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_jdbc_connector.sh" do
  source "hopssite/hs_jdbc_connector.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_realm_setup.sh" do
  source "hopssite/hs_realm_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_domain2_certs.sh" do
  source "hopssite/hs_domain2_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_glassfish_sign.sh" do
  source "hopssite/hs_glassfish_sign.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_glassfish_certs.sh" do
  source "hopssite/hs_glassfish_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_ssl_setup.sh" do
  source "hopssite/hs_ssl_setup.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_admin_certs.sh" do
  source "hopssite/hs_admin_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_redeploy.sh" do
  source "hopssite/hs_redeploy.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_elastic.sh" do
  source "hopssite/hs_elastic.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_dela_certs.sh" do
  source "hopssite/hs_dela_certs.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_purge.sh" do
  source "hopssite/hs_purge.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_tables.sql" do
  source "hopssite/hs_tables.sql.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_rows.sql" do
  source "hopssite/hs_rows.sql.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/glassfish-domain2.service" do
  source "hopssite/glassfish-domain2.service.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/hs_systemctl.sh" do
  source "hopssite/hs_systemctl.sh.erb"
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action :create
  mode 0755
end
#END hopssite install scripts
