FROM alpine:latest

LABEL maintainer="veoco <one@nomox.cn>"

RUN apk update \
&& apk add caddy supervisor \
&& apk add php7 php7-fpm php7-opcache php7-ctype php7-pdo_sqlite php7-session php7-curl php7-tokenizer php7-mbstring \
&& mkdir -p /etc/conf \
&& mkdir -p /data/run \
&& mkdir -p /data/log \
&& mkdir -p /data/www \
&& rm -f /etc/init.d/caddy\
&& rm -f /etc/init.d/php-fpm7\
&& wget http://typecho.org/downloads/1.1-17.10.30-release.tar.gz \
&& tar zxf 1.1-17.10.30-release.tar.gz \
&& rm -f 1.1-17.10.30-release.tar.gz \
&& mv build/* /data/www/ \
&& rm -rf build/ \
&& chown -R caddy:caddy /data/www

COPY ["src/caddy.conf", "src/php-fpm.conf", "src/supervisord.conf", "/etc/conf/"]

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/conf/supervisord.conf"]