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

bash 'remove-glassfish' do
  user "root"
  ignore_failure true
  code <<-EOF
      service glassfish-domain1 stop
      systemctl stop glassfish-domain1
      pid=$(sudo netstat -lptn | grep 4848 | awk '{print $7}')
      pid=echo "${pid//[!0-9]/}"
      if [ $pid != "" ] ; then
         kill $pid
      fi
      rm -rf #{node['glassfish']['domains_dir']}
      rm -rf #{node['glassfish']['install_dir']}/glassfish
      rm -f /etc/init.d/glassfish-domain1
      rm -f /usr/lib/systemd/system/glassfish-domain1.service
      rm -f /lib/systemd/system/glassfish-domain1.service
      rm -f /etc/systemd/system/glassfish-domain1.service
  EOF
end

directory "#{node['glassfish']['install_dir']}/glassfish" do
  recursive true
  action :delete
  ignore_failure true
end

directory "#{node['glassfish']['domains_dir']}" do
  recursive true
  action :delete
  ignore_failure true
end



