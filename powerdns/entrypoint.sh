#!/bin/sh

[ -z ${PDNS_SQLITE_CONF_FILE} ] && PDNS_SQLITE_CONF_FILE=/etc/pdns/pdns-sqlite.conf
[ -z ${PDNS_SQLITE_DB_FILE} ] && PDNS_SQLITE_DB_FILE=/db/pdns.sqlite
[ -z ${PDNS_SQLITE_SCHEMA_FILE} ] && PDNS_SQLITE_SCHEMA_FILE=/usr/share/doc/pdns/schema.sqlite3.sql
[ -z ${PDNS_SQLITE_API_KEY} ] && PDNS_SQLITE_API_KEY="changeme"

[ -z ${PDNS_SQLITE_UID} ] && PDNS_SQLITE_UID=1000
[ -z ${PDNS_SQLITE_GID} ] && PDNS_SQLITE_GID=1000

[ ! -s $PDNS_SQLITE_DB_FILE ] && sqlite3 $PDNS_SQLITE_DB_FILE < $PDNS_SQLITE_SCHEMA_FILE

chown ${PDNS_SQLITE_UID}:${PDNS_SQLITE_GID} $PDNS_SQLITE_DB_FILE

groupmod -g ${PDNS_SQLITE_GID} pdns
usermod -u ${PDNS_SQLITE_UID} pdns

sed \
        -e 's/.*chroot/#chroot/' \
        -e 's/.*daemon=.*/daemon=no/' \
        -e 's/.*distributor-threads.*/distributor-threads=3/' \
        -e 's/.*guardian=.*/guardian=no/' \
        -e 's/.*launch=.*/launch=gsqlite3/' \
        -e 's/.*use-logfile/#use-logfile/' \
        -e 's/.*webserver=.*/webserver=yes/' \
        -e 's/.*webserver-address=.*/webserver-address=0.0.0.0/' \
        -e 's/.*wildcards/#wildcards/' \
        /etc/pdns/pdns.conf > $PDNS_SQLITE_CONF_FILE

cat << EOF >> $PDNS_SQLITE_CONF_FILE
api=yes
api-key=$PDNS_SQLITE_API_KEY
disable-syslog=yes
gsqlite3-database=$PDNS_SQLITE_DB_FILE
webserver-allow-from=0.0.0.0/0,::0
write-pid=no
EOF

pdns_server --config-name=sqlite

