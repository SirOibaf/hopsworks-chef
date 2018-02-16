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

directory node['hopssite']['home'] do
  owner node['hopsworks']['user']
  mode 0755
  action :create
end

template "#{node['hopssite']['home']}/register.sh" do
  source "dela/register.sh.erb"
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  action :create
  mode 0755
end

template "#{node['hopssite']['home']}/register_data.json" do
  source "dela/register_data.json.erb"
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  action :create
  mode 0644
end

bash "register" do
  user node['hopsworks']['user']
  code <<-EOF
    set -e
    #{node['hopssite']['home']}/register.sh
  EOF
end
