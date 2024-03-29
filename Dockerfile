FROM alpine:3.19

RUN apk add --no-cache \
    mariadb-client \
    pdns=4.8.3-r2 \
    pdns-backend-mysql=4.8.3-r2 \
    pdns-doc=4.8.3-r2 \
    py3-pip \
    python3

ENV PATH "/opt/venv/bin:$PATH"

RUN python3 -m venv /opt/venv \
    && pip3 install --no-cache-dir envtpl

ENV VERSION=4.8 \
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

