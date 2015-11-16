#!/bin/bash

/etc/init.d/tomcat7 start

# The container will run as long as the script is running, that's why
# we need something long-lived here

exec tail -f /var/lib/tomcat7/logs/catalina.out