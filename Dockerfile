FROM alpine:edge AS build-stage

# Install envtpl
ENV PATH="/opt/venv/bin:$PATH"
RUN apk add \
    python3 \
    binutils \
    libffi-dev \
    && python3 -m venv /opt/venv \
    && pip3 install --no-cache-dir envtpl pyinstaller \
    && pyinstaller -F /opt/venv/lib/python3.12/site-packages/envtpl.py

FROM alpine:edge

COPY --from=build-stage --chown=root:root /dist/envtpl /usr/local/bin/

RUN apk add --no-cache \
    mariadb-client \
    pdns=4.9.1-r0 \
    pdns-backend-mysql=4.9.1-r0 \
    pdns-backend-pgsql=4.9.1-r0 \
    pdns-doc=4.9.1-r0

ENV VERSION=4.9 \
    PDNS_guardian=yes \
    PDNS_setuid=pdns \
    PDNS_setgid=pdns \
    PDNS_launch=gmysql

EXPOSE 53 53/udp

COPY pdns.conf.tpl /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Fix DB schema
RUN sed -i 's/CREATE TABLE/CREATE TABLE IF NOT EXISTS/g ; s/CREATE UNIQUE INDEX/CREATE UNIQUE INDEX IF NOT EXISTS/g ; s/CREATE INDEX/CREATE INDEX IF NOT EXISTS/g' /usr/share/doc/pdns/schema.mysql.sql \
    && sed -i 's/CREATE TABLE/CREATE TABLE IF NOT EXISTS/g ; s/CREATE UNIQUE INDEX/CREATE UNIQUE INDEX IF NOT EXISTS/g ; s/CREATE INDEX/CREATE INDEX IF NOT EXISTS/g' /usr/share/doc/pdns/schema.pgsql.sql

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_server" ]

