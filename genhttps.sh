#!/bin/sh

cat <<EOF > /etc/apache2/conf.d/ssl.conf
LoadModule ssl_module /usr/lib/apache2/mod_ssl.so
LoadModule socache_shmcb_module /usr/lib/apache2/mod_socache_shmcb.so
SSLRandomSeed startup file:/dev/urandom 512
SSLRandomSeed connect builtin
SSLCipherSuite HIGH:MEDIUM:!SSLv3:!kRSA
SSLProxyCipherSuite HIGH:MEDIUM:!SSLv3:!kRSA
SSLHonorCipherOrder on
SSLProtocol all -SSLv3 -TLSv1
SSLProxyProtocol all -SSLv3 -TLSv1
SSLPassPhraseDialog  builtin
SSLSessionCache        "shmcb:/var/cache/mod_ssl/scache(512000)"
SSLSessionCacheTimeout  300
SSLUseStapling On
SSLStaplingCache "shmcb:/run/apache2/ssl_stapling(32768)"
SSLStaplingStandardCacheTimeout 3600
SSLStaplingErrorCacheTimeout 600
EOF

cat <<EOF > /etc/apache2/conf.d/vhost-https.conf
Listen $HTTPSPORT
<VirtualHost _default_:$HTTPSPORT>
DocumentRoot "$DOCROOT"
ServerName $SERVERNAME:$HTTPSPORT
ServerAdmin $SERVERADMIN
ErrorLog /dev/stderr
TransferLog /dev/stdout
SSLEngine on
SSLCertificateFile /etc/letsencrypt/live/$SERVERNAME/cert.pem
SSLCertificateKeyFile /etc/letsencrypt/live/$SERVERNAME/privkey.pem
SSLCertificateChainFile /etc/letsencrypt/live/$SERVERNAME/chain.pem
SSLCACertificatePath /etc/ssl/certs/

<FilesMatch "\\.(cgi|shtml|phtml|php)\$">
    SSLOptions +StdEnvVars
</FilesMatch>
<Directory "/var/www/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>
CustomLog /dev/stdout "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"
</VirtualHost>
EOF

