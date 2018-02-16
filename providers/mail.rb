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

action :jndi do

decoded = node['hopsworks']['email_password']

# If the email_password is the 'default' password
if decoded.eql? "password"
  decoded = ::File.read("#{Chef::Config['file_cache_path']}/hopsworks.encoded")
  node.override['hopsworks']['email_password'] = decoded
end

gmailProps = {
  'mail-smtp-host' => node['hopsworks']['smtp'],
  'mail-smtp-user' => node['hopsworks']['email'],
  'mail-smtp-password' => decoded,
  'mail-smtp-auth' => 'true',
  'mail-smtp-port' => node['hopsworks']['smtp_port'],
  'mail-smtp-socketFactory-port' => node['hopsworks']['smtp_ssl_port'],
  'mail-smtp-socketFactory-class' => 'javax.net.ssl.SSLSocketFactory',
  'mail-smtp-starttls-enable' => 'true',
  'mail.smtp.ssl.enable' => 'true',
  'mail-smtp-socketFactory-fallback' => 'false'
}

 Chef::Log.info("gmail password is #{decoded}")

 glassfish_javamail_resource "gmail" do
   jndi_name "mail/BBCMail"
   mailuser node['hopsworks']['email']
   mailhost node['hopsworks']['smtp']
   fromaddress node['hopsworks']['email']
   properties gmailProps
   domain_name "#{new_resource.domain_name}"
   password_file "#{new_resource.password_file}"
   username "#{new_resource.username}"
   admin_port new_resource.admin_port
   secure false
   action :create
 end


end
