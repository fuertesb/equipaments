FROM registry.swarmme.cpd1.intranet.gencat.cat:5000/alpine-tomcat7-apache

MAINTAINER bfuertes <benjami.fuertes@hpe.com>

LABEL Description="Demo canigó" Vendor="hpe.com" Version="1.1"

# Default dev values

# not really used
ENV DB_USER canigo
ENV DB_PASS canigo2015
ENV DB_CONNECTION_STRING jdbc:mysql://30.34.129.32:3306/equipaments
ENV DB_DRIVER com.mysql.jdbc.Driver

ENV CATALINA_OPTS '-Dentorn=docker'

# Afegim war i statics.
# TODO: get names from env var

ADD /target/equipaments.war /usr/tomcat/webapps/equipaments.war
ADD /target/equipaments.zip /var/www/localhost/htdocs/
ADD /index.html /var/www/localhost/htdocs/index.html

# Afegim templates, scripts i dependencies
ADD /docker /

#Afegim el healthcheck
HEALTHCHECK CMD /root/healthcheck.sh

#Afegim curl a la imatge.
RUN apk --update add curl

# Donem permisos al setup.sh
RUN chmod +x /root/setup.sh /root/healthcheck.sh

# Descomprimim els statics.
RUN unzip -o /var/www/localhost/htdocs/equipaments.zip -d /var/www/localhost/htdocs/ && \
rm /var/www/localhost/htdocs/equipaments.zip

