FROM alpine:edge

RUN apk add --no-cache \
    mariadb-client \
    pdns=4.9.0-r1 \
    pdns-backend-mysql=4.9.0-r1 \
    pdns-doc=4.9.0-r1 \
    && apk add --no-cache --virtual .build-deps curl \
    && curl -L https://github.com/matt-allan/envtpl/releases/download/0.4.0/x86_64-linux.tar.xz | tar -xJ --strip-components=1 -C /usr/local/bin/ \
    && apk del .build-deps

ENV VERSION=4.9 \
    PDNS_guardian=yes \
    PDNS_setuid=pdns \
    PDNS_setgid=pdns \
    PDNS_launch=gmysql

EXPOSE 53 53/udp

COPY pdns.conf.tpl /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_server" ]

