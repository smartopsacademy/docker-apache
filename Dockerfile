FROM alpine:latest
MAINTAINER SmartOps Academy <docker@smartops.academy>

RUN apk update \
 && apk add apache2 apache2-ssl apache2-utils ca-certificates apache2-proxy \
 && rm -f /etc/apache2/conf.d/info.conf \
 && rm -f /etc/apache2/conf.d/ssl.conf \
 && rm -f /etc/apache2/conf.d/userdir.conf \
 && rm -f /etc/apache2/conf.d/proxy.conf

COPY apache/ /etc/apache2/
COPY genhttps.sh /usr/local/bin/
COPY apachestart.sh /usr/local/bin/

WORKDIR /var/www
CMD ["/usr/local/bin/apachestart.sh"]
