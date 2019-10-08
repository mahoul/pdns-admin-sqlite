#!/bin/bash

if [ $# -gt 0 ]; then
	PDNS_IP=$1
	PDNS_ADMIN_IP=${PDNS_IP}
	sed -e "s/.*PDNS_SQLITE_UID=.*/PDNS_SQLITE_UID=$(id -u)/" \
	    -e "s/.*PDNS_SQLITE_GID=.*/PDNS_SQLITE_GID=$(id -g)/" \
	    -e "s/.*PDNS_ADMIN_IP=.*/PDNS_ADMIN_IP=${PDNS_ADMIN_IP}/" \
	    -e "s/.*PDNS_IP=.*/PDNS_IP=${PDNS_IP}/" \
	    .env-dist > .env
else
	sed -e "s/.*PDNS_SQLITE_UID=.*/PDNS_SQLITE_UID=$(id -u)/" \
	    -e "s/.*PDNS_SQLITE_GID=.*/PDNS_SQLITE_GID=$(id -g)/" \
	    .env-dist > .env
fi

docker-compose up -d

