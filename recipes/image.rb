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
# For the Hopsworks Virtualbox Instance, autologin and autostart a browser.
# Only for Ubuntu
#

package 'lightdm'
package 'ubuntu-desktop'
package "mingetty"

bash 'mkdir_autostart' do
  user 'root'
  ignore_failure true
  code <<-EOF
       mkdir -p /home/#{node['glassfish']['user']}/.config/autostart
       chown -R #{node['glassfish']['user']}  /home/#{node['glassfish']['user']}/.config
       groupadd -r autologin
       gpasswd -a #{node['glassfish']['user']} autologin
    EOF
end


#
# Firefox desktop entry should start after hops-services.desktop.
# Change firefox name to 'x' so that it starts last.
#
template "/home/#{node['glassfish']['user']}/.config/autostart/x-firefox.desktop" do
    source "virtualbox/firefox.desktop.erb"
    owner node['glassfish']['user']
    mode 0774
    action :create
end

template "/home/#{node['glassfish']['user']}/.config/autostart/hops-services.desktop" do
    source "virtualbox/hops-services.desktop.erb"
    owner node['glassfish']['user']
    mode 0774
    action :create
end



template "/etc/init/tty1.conf" do
    source "virtualbox/tty.conf.erb"
    owner "root"
    mode 0644
    action :create
end

template "/etc/lightdm/lightdm.conf" do
    source "virtualbox/lightdm.conf.erb"
    owner "root"
    mode 0644
    action :create
end



#
#
#

service "lightdm" do
  service_name node["lightdm"]["service_name"]
  action [:enable, :start]
end


mount "/vagrant" do
  action :disable
  ignore_failure true
end
