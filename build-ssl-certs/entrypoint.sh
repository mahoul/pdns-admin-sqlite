#!/bin/sh -x

[ -z "${SSL_COUNTRY}" ]  && SSL_COUNTRY="MW"
[ -z "${SSL_STATE}" ]    && SSL_STATE="New Canaan"
[ -z "${SSL_LOCALITY}" ] && SSL_LOCALITY="Gilead"
[ -z "${SSL_CODE}" ]     && SSL_CODE="00003"
[ -z "${SSL_ADDRESS}" ]  && SSL_ADDRESS="Castle Complex, 1"
[ -z "${SSL_ORG}" ]      && SSL_ORG="Tet Corporation"
[ -z "${SSL_ORG_UNIT}" ] && SSL_ORG_UNIT="Gunslingers"
[ -z "${SSL_COMMON}" ]   && SSL_COMMON="ny.tet.lan"
[ -z "${SSL_EMAIL}" ]    && SSL_EMAIL="dinn@tet.lan"

SSL_PATH=/tmp/ssl-certs
SSL_CONF=$SSL_PATH/openssl.cnf
SSL_CERT=$SSL_PATH/${SSL_COMMON}.crt
SSL_KEY=$SSL_PATH/${SSL_COMMON}.key

[ -z ${PDNS_SQLITE_UID} ] && PDNS_SQLITE_UID=1000
[ -z ${PDNS_SQLITE_GID} ] && PDNS_SQLITE_GID=1000

[ $(id -u ssl-user ) -ne ${PDNS_SQLITE_UID} ] && usermod -u ${PDNS_SQLITE_UID} ssl-user
[ $(id -g ssl-user ) -ne ${PDNS_SQLITE_GID} ] && groupmod -g ${PDNS_SQLITE_GID} ssl-user

su -c "sh -x -s" ssl-user <<EOS
for common in $(echo $SSL_COMMON | tr "," " "); do

[ -s ${SSL_CONF}-\${common} ] && [ -s $SSL_PATH/\${common}.crt ] && [ -s $SSL_PATH/\${common}.key ] && continue

cat <<-EOF > ${SSL_CONF}-\${common}

[ req ]
prompt  = no

distinguished_name = req_distinguished_name

[ req_distinguished_name ]
countryName            = ${SSL_COUNTRY}           # C=
stateOrProvinceName    = ${SSL_STATE}             # ST=
localityName           = ${SSL_LOCALITY}          # L=
postalCode             = ${SSL_CODE}              # L/postalcode=
streetAddress          = ${SSL_ADDRESS}           # L/street=
organizationName       = ${SSL_ORG}               # O=
organizationalUnitName = ${SSL_ORG_UNIT}          # OU=
commonName             = \${common}                # CN=
emailAddress           = root@\${common}           # CN/emailAddress=

EOF

openssl req \
        -x509 \
        -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -config $SSL_CONF-\${common} \
        -keyout $SSL_PATH/\${common}.key \
        -out $SSL_PATH/\${common}.crt

chmod 664 $SSL_PATH/*

done
EOS

