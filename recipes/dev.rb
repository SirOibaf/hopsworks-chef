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

bash 'dev-setup' do
    user "root"
    code <<-EOF
       apt-get install git -y
       apt-get install nodejs -y
       apt-get install npm -y
       npm install -g bower
       ln -s /usr/bin/nodejs /usr/bin/node

# Turn-on debug mode for both sysv and systemd init scripts
       perl -pi -e "s/--debug false/--debug true/g" /etc/init.d/glassfish-domain1
       perl -pi -e "s/--debug false/--debug true/g" /etc/systemd/system/glassfish-domain1.service
       perl -pi -e "s/--debug false/--debug true/g" /lib/systemd/system/glassfish-domain1.service
       chown -R #{node['hopsworks']['user']} /home/#{node['hopsworks']['user']}/.config
       systemctl stop glassfish-domain1
       systemctl daemon-reload
       sleep 1
       systemctl start glassfish-domain1


#       cd #{node['hopsworks']['domains_dir']}/domain1/bin
#       myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
#       fqdn=$(dig -x $myip | egrep '.*\s+[0-9]+\s+IN.*' | awk '{print $5}')
       # remove trailing '.' from the hostname
#       fqdn=${fqdn::-1}
#       ./letsencypt.sh #{node['hopsworks']['cert']['password']} 0001 $fqdn
    EOF
  end


