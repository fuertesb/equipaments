#!/bin/sh

echo "Running setup.sh"

# Preserve original template
cp /root/templates/context.tmpl /root/templates/context.tmp

sed -i 's#%DB_USER%#'"$DB_USER"'#g' /root/templates/context.tmp
sed -i 's#%DB_PASS%#'"$DB_PASS"'#g' /root/templates/context.tmp
sed -i 's#%DB_CONNECTION_STRING%#'"$DB_CONNECTION_STRING"'#g' /root/templates/context.tmp
sed -i 's#%DB_DRIVER%#'"$DB_DRIVER"'#g' /root/templates/context.tmp

# TODO: Modificar el fixer del apache si cal
cp /root/templates/apache.tmpl /root/templates/apache.tmp

mv /root/templates/context.tmp  /usr/tomcat/conf/context.xml
mv /root/templates/apache.tmp  /etc/apache2/conf.d/apache.conf
