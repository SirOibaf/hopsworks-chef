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


if node['glassfish']['port'] == 80


    case node['platform_family']
    when "redhat"
      bash "authbind-centos" do
        user "root"
        code <<-EOF
         cd /tmp
         wget http://ftp.debian.org/debian/pool/main/a/authbind/authbind_2.1.1.tar.gz
         tar zxf http://ftp.debian.org/debian/pool/main/a/authbind/authbind_2.1.1.tar.gz
         cd authbind-2.1.1
         make
         make install
         ln -s /usr/local/bin/authbind /usr/bin/authbind
         mkdir -p /etc/authbind/byport
         touch /etc/authbind/byport/80
         chmod 550 /etc/authbind/byport/80
         perl -pi -e 's/8080/80/g' #{node['glassfish']['domains_dir']}/domain1/config/domain.xml
     EOF
      end

    end
      bash "authbind-common" do
        user "root"
        code <<-EOF
         perl -pi -e 's/8181/443/g' #{node['glassfish']['domains_dir']}/domain1/config/domain.xml
         touch /etc/authbind/byport/443
         chown #{node['glassfish']['user']} /etc/authbind/byport/443
         chmod 550 /etc/authbind/byport/443
   EOF
      end

end
