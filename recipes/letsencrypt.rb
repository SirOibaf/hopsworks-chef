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

myHost=node['fqdn']
keytool="#{node['java']['java_home']}/bin/keytool"


bash 'letsencrypt-run' do
    user "root"
    cwd "/tmp"
    code <<-EOF
      cd /tmp
      git clone https://github.com/certbot/certbot
      cd certbot
      ./certbot-auto certonly --standalone -d hops.site -d www.hops.site
EOF
end


bash 'letsencrypt-setup' do
    user "root"
    cwd "/tmp"
    code <<-EOF
	DOMAIN=#{myHost}
	KEYSTOREPW=#{node['hopsworks']['master']['password']}
	GFDOMAIN=#{node['glassfish']['domains_dir']}/domain1

	#TODO Define Attribute
	LIVE=/etc/letsencrypt/live/$DOMAIN

	#Backup Keystore & Truststore
	cp -f $GFDOMAIN/config/keystore.jks keystore.jks.backup
	cp -f $GFDOMAIN/config/cacerts.jks cacerts.jks.backup

	#Make a temp. copy of the Trusstore
	cp -f $GFDOMAIN/config/cacerts.jks .

	#Delete Oracle Cert from Truststore
	#{keytool} -delete -alias s1as -keystore cacerts.jks -storepass $KEYSTOREPW
	#{keytool} -delete -alias glassfish-instance -keystore cacerts.jks -storepass $KEYSTOREPW

	#Create new Keystore using the LetsEncrypt Certificates
	openssl pkcs12 -export -in $LIVE/cert.pem -inkey $LIVE/privkey.pem -out cert_and_key.p12 -name $DOMAIN -CAfile $LIVE/chain.pem -caname root -password pass:$KEYSTOREPW
	#{keytool} -importkeystore -destkeystore keystore.jks -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias $DOMAIN -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW
	#{keytool} -import -noprompt -trustcacerts -alias root -file $LIVE/chain.pem -keystore keystore.jks -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

	openssl pkcs12 -export -in $LIVE/fullchain.pem -inkey $LIVE/privkey.pem -out pkcs.p12 -name glassfish-instance -password pass:$KEYSTOREPW
	#{keytool} -importkeystore -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -alias glassfish-instance -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW
	openssl pkcs12 -export -in $LIVE/fullchain.pem -inkey $LIVE/privkey.pem -out pkcs.p12 -name s1as -password pass:$KEYSTOREPW
	#{keytool} -importkeystore -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -alias s1as -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

	#Print out contents of the newly created Keystore
	#{keytool} -list -keystore keystore.jks -storepass $KEYSTOREPW

	#Add new Certificates to Truststore
	#{keytool} -export -alias glassfish-instance -file glassfish-instance.cert -keystore keystore.jks -storepass $KEYSTOREPW
	#{keytool} -export -alias s1as -file s1as.cert -keystore keystore.jks -storepass $KEYSTOREPW

	#{keytool} -import -noprompt -alias s1as -file s1as.cert -keystore cacerts.jks -storepass $KEYSTOREPW
	#{keytool} -import -noprompt -alias glassfish-instance -file glassfish-instance.cert -keystore cacerts.jks -storepass $KEYSTOREPW
	#Replace old Keystore & Truststore
	cp -f keystore.jks cacerts.jks $GFDOMAIN/config/
	chown -R #{node['glassfish']['user']} $GFDOMAIN/config/

	touch #{node['glassfish']['base_dir']}/.letsencypt_installed
  	chown #{node['glassfish']['user']} #{node['glassfish']['base_dir']}/.letsencypt_installed

	#Restart Glassfish
	service glassfish-domain1 stop
	sleep 1
	service glassfish-domain1 start

    EOF
 not_if { ::File.exists?( "#{node['glassfish']['base_dir']}/.letsencypt_installed" ) }
end
