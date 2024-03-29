#!/bin/sh

: "${SERVERNAME:=unconfigured-apache-server}"
: "${SERVERADMIN:=admin@example.com}"
: "${HTTPPORT:=80}"
: "${DOCROOT:=/var/www}"

if [ ! -d ${DOCROOT} ] ; then
    mkdir -p ${DOCROOT}
fi

mkdir -p /run/apache2
chown root.root /etc/ssl/apache2/*
chmod 600 /etc/ssl/apache2/*

if [ ! -f /etc/apache2/conf.d/01main.conf ] ; then
cat <<EOF > /etc/apache2/conf.d/01main.conf
Listen ${HTTPPORT}
ServerAdmin ${SERVERADMIN}
ServerName ${SERVERNAME}:${HTTPPORT}
DocumentRoot "${DOCROOT}"
<Directory "${DOCROOT}">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
fi

if [ x${FCGI} != "x" ] ; then
cat <<EOF > /etc/apache2/conf.d/fcgi.conf
LoadModule proxy_module /usr/lib/apache2/mod_proxy.so
LoadModule proxy_fcgi_module /usr/lib/apache2/mod_proxy_fcgi.so
<IfModule mod_proxy_fcgi.c>
        ProxyPassMatch "^/(.*\\.php(/.*)?)$" "fcgi://${FCGI}${DOCROOT}/\$1"
	ProxyTimeout 600
        DirectoryIndex /index.php index.php
	ProxyVia Block
</IfModule>
EOF
fi

exec /usr/sbin/httpd -DFOREGROUND
