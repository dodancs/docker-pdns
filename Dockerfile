FROM alpine:3.17

RUN apk add --no-cache \
    mariadb-client \
    pdns=4.7.2-r0 \
    pdns-backend-mysql=4.7.2-r0 \
    pdns-doc=4.7.2-r0 \
    py3-pip \
    python3

RUN pip3 install --no-cache-dir 'Jinja2<3.1' envtpl

ENV VERSION=4.7 \
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

