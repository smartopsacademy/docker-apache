#!/bin/sh

: "${SERVERNAME:=unconfigured-apache-server}"
: "${SERVERADMIN:=admin@example.com}"
: "${HTTPPORT:=80}"
: "${DOCROOT:=/var/www/html}"

if [ ! -d $DOCROOT ] ; then
    echo "The Document root DOCROOT=$DOCROOT doesn't exists."
    exit 1
fi

mkdir -p /run/apache2
chown root.root /etc/ssl/apache2/*
chmod 600 /etc/ssl/apache2/*

cat <<EOF > /etc/apache2/conf.d/01main.conf
Listen $HTTPPORT
ServerAdmin $SERVERADMIN
ServerName $SERVERNAME:$HTTPPORT
DocumentRoot "$DOCROOT"
<Directory "$DOCROOT">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF

if [ x$HTTPSPORT != "x" ] ; then
    /usr/local/bin/genhttps.sh
fi

if [ x$FCGI != "x" ] ; then
cat <<EOF > /etc/apache2/conf.d/fcgi.conf
LoadModule proxy_module /usr/lib/apache2/mod_proxy.so
LoadModule proxy_fcgi_module /usr/lib/apache2/mod_proxy_fcgi.so
<IfModule mod_proxy_fcgi.c>
        ProxyPassMatch "^/(.*\\.php(/.*)?)$" "fcgi://$FCGI$DOCROOT/\$1"
	ProxyTimeout 600
        DirectoryIndex /index.php index.php
	ProxyVia Block
</IfModule>
EOF
fi

apachectl configtest
exec /usr/sbin/httpd -DFOREGROUND
