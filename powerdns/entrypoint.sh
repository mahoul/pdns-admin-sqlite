#!/bin/sh -x

[ -z ${PDNS_SQLITE_CONF_FILE} ] && PDNS_SQLITE_CONF_FILE=/etc/pdns/pdns-sqlite.conf
[ -z ${PDNS_SQLITE_DB_FILE} ] && PDNS_SQLITE_DB_FILE=/db/pdns.sqlite
[ -z ${PDNS_SQLITE_SCHEMA_FILE} ] && PDNS_SQLITE_SCHEMA_FILE=/usr/share/doc/pdns/schema.sqlite3.sql
[ -z ${PDNS_SQLITE_API_KEY} ] && PDNS_SQLITE_API_KEY="changeme"

[ -z ${PDNS_SQLITE_UID} ] && PDNS_SQLITE_UID=1000
[ -z ${PDNS_SQLITE_GID} ] && PDNS_SQLITE_GID=1000

[ ! -s $PDNS_SQLITE_DB_FILE ] && sqlite3 $PDNS_SQLITE_DB_FILE < $PDNS_SQLITE_SCHEMA_FILE

[ $(id -u pdns) -ne ${PDNS_SQLITE_UID} ] && usermod -u ${PDNS_SQLITE_UID} pdns
[ $(id -g pdns) -ne ${PDNS_SQLITE_GID} ] && groupmod -g ${PDNS_SQLITE_GID} pdns

sed \
        -e 's/.*chroot/#chroot/' \
        -e 's/.*daemon=.*/daemon=no/' \
        -e 's/.*distributor-threads.*/distributor-threads=3/' \
        -e 's/.*guardian=.*/guardian=no/' \
        -e 's/.*launch=.*/launch=gsqlite3/' \
        -e 's/.*local-port=.*/local-port=5301/' \
        -e 's/.*socket-dir=.*/socket-dir=\/var\/run\/pdns/' \
        -e 's/.*use-logfile/#use-logfile/' \
        -e 's/.*webserver=.*/webserver=yes/' \
        -e 's/.*webserver-address=.*/webserver-address=0.0.0.0/' \
        -e 's/.*wildcards/#wildcards/' \
        /etc/pdns/pdns.conf > $PDNS_SQLITE_CONF_FILE


if [ -n ${PDNS_UPDATES} ] && [ "${PDNS_UPDATES}" == "yes" ]; then
	cat <<-EOF >> $PDNS_SQLITE_CONF_FILE
	allow-dnsupdate-from=0.0.0.0/0,::0
	dnsupdate=yes
	EOF
fi

cat << EOF >> $PDNS_SQLITE_CONF_FILE
api=yes
api-key=$PDNS_SQLITE_API_KEY
disable-syslog=yes
dnsupdate=yes
gsqlite3-database=$PDNS_SQLITE_DB_FILE
webserver-allow-from=0.0.0.0/0,::0
write-pid=no
EOF

chown -R pdns:pdns /etc/pdns /db /var/run/pdns

pdns_server --config-name=sqlite

