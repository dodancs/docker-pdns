#! /bin/sh

set -euo pipefail

if [ "${PDNS_gmysql_host:-}" != "" ]; then
    echo "Running migrations on the database..."

    SQL_COMMAND="mysql -h ${PDNS_gmysql_host} -P ${PDNS_gmysql_port} -u ${PDNS_gmysql_user} -p${PDNS_gmysql_password} -D ${PDNS_gmysql_dbname}"

    # Initialize DB if needed
    $SQL_COMMAND </usr/share/doc/pdns/schema.mysql.sql

    echo "Done."
fi

if [ "${PDNS_gpgsql_host:-}" != "" ]; then
    echo "Running migrations on the database..."

    export PGPASSWORD=${PDNS_gpgsql_password}
    SQL_COMMAND="psql -h ${PDNS_gpgsql_host} -p ${PDNS_gpgsql_port} -U ${PDNS_gpgsql_user} -w ${PDNS_gpgsql_dbname}"

    # Initialize DB
    $SQL_COMMAND </usr/share/doc/pdns/schema.pgsql.sql

    echo "Done."
fi

if [ "${PDNS_autosecondary:-no}" == "yes" ]; then
    # Configure masters for secondary if needed
    if [ "${SUPERMASTER_IPS:-}" != "" ]; then
        echo "Inserting masters for autosecondary..."
        echo "TRUNCATE supermasters;" | $SQL_COMMAND

        SUPERMASTERS=$($SUPERMASTER_IPS | sed 's/,/"), ("/g ; s/^/("/ ; s/$/")/ ; s/:/","/g')
        echo "INSERT INTO supermasters VALUES $SUPERMASTERS;" | $SQL_COMMAND
        echo "Done."
    fi
fi

# Create config file from template
envtpl </pdns.conf.tpl >/etc/pdns/pdns.conf

exec "$@"
