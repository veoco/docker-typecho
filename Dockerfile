FROM alpine:latest

LABEL maintainer="veoco <one@nomox.cn>"

RUN apk update \
&& apk add caddy supervisor \
&& apk add php7 php7-fpm php7-opcache php7-ctype php7-pdo_sqlite php7-session php7-curl php7-tokenizer php7-mbstring

COPY src/install.sh /tmp/

RUN chmod +x /tmp/install.sh \
&& /tmp/install.sh

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisord/supervisord.conf"]