#!/bin/sh

#Based in work from Alejandro Escanero Blanco "aescanero" (https://github.com/aescanero/docker-powerdns-admin-alpine)
#Based in work from Khanh Ngo "k@ndk.name" (https://github.com/ngoduykhanh/PowerDNS-Admin/blob/master/docker/PowerDNS-Admin/Dockerfile)

DB_MIGRATION_DIR='/opt/pdnsadmin/migrations'

[ -z ${PDNS_PROTO} ] && PDNS_PROTO="http"
[ -z ${PDNS_PORT} ] && PDNS_PORT=8081
[ -z ${PDNS_HOST} ] && PDNS_HOST="127.0.0.1"
[ -z ${PDNS_API_KEY} ] && PDNS_API_KEY="changeme"
[ -z ${PDNSADMIN_PORT} ] && PDNSADMIN_PORT=9191
[ -z ${PDNSADMIN_SECRET_KEY} ] && PDNSADMIN_SECRET_KEY='secret'
[ -z ${SQLA_DB_FILE} ] && SQLA_DB_FILE='/db/pdns-admin.sqlite'


cat >/opt/pdnsadmin/config.py <<EOF
import os
basedir = os.path.abspath(os.path.dirname(__file__))
BIND_ADDRESS = '0.0.0.0'
TIMEOUT = 10
LOG_LEVEL = 'ALERT'
LOG_FILE = 'logfile.log'
SALT = '$2b$12$yLUMTIfl21FKJQpTkRQXCu'
UPLOAD_DIR = os.path.join(basedir, 'upload')
SAML_ENABLED = False
SAML_DEBUG = False
SAML_PATH = os.path.join(os.path.dirname(__file__), 'saml')
SAML_METADATA_URL = 'https://<hostname>/FederationMetadata/2007-06/FederationMetadata.xml'
SAML_METADATA_CACHE_LIFETIME = 1
SAML_ATTRIBUTE_ACCOUNT = 'https://example.edu/pdns-account'
SAML_SP_ENTITY_ID = 'http://<SAML SP Entity ID>'
SAML_SP_CONTACT_NAME = '<contact name>'
SAML_SP_CONTACT_MAIL = '<contact mail>'
SAML_SIGN_REQUEST = False
SAML_LOGOUT = False
EOF

echo "SECRET_KEY = '${PDNSADMIN_SECRET_KEY}'" >>/opt/pdnsadmin/config.py
echo "PORT = ${PDNSADMIN_PORT}" >>/opt/pdnsadmin/config.py
echo "SQLA_DB_FILE = '${SQLA_DB_FILE}'" >>/opt/pdnsadmin/config.py

cat >>/opt/pdnsadmin/config.py <<EOF
SQLALCHEMY_TRACK_MODIFICATIONS = True
SQLALCHEMY_DATABASE_URI = 'sqlite:///' + SQLA_DB_FILE
EOF

cd /opt/pdnsadmin
virtualenv --system-site-packages --no-setuptools --no-pip flask
source ./flask/bin/activate

echo "===> DB management"
if [ ! -d "${DB_MIGRATION_DIR}" ]; then
  echo "---> Running DB Init"
  flask db init --directory ${DB_MIGRATION_DIR}
  flask db migrate -m "Init DB" --directory ${DB_MIGRATION_DIR}
  flask db upgrade --directory ${DB_MIGRATION_DIR}
#  ./init_data.py
else
  echo "---> Running DB Migration"
  flask db migrate -m "Upgrade DB Schema" --directory ${DB_MIGRATION_DIR}
  flask db upgrade --directory ${DB_MIGRATION_DIR}
fi

echo "===> Update PDNS API connection info"
# initial setting if not available in the DB
sqlite3 ${SQLA_DB_FILE} <<EOF
INSERT INTO setting (name, value) SELECT * FROM (SELECT 'pdns_api_url',
 '${PDNS_PROTO}://${PDNS_HOST}:${PDNS_PORT}') AS tmp WHERE NOT EXISTS (SELECT name FROM setting WHERE name = 'pdns_api_url') LIMIT 1;
INSERT INTO setting (name, value) SELECT * FROM (SELECT 'pdns_api_key',
 '${PDNS_API_KEY}') AS tmp WHERE NOT EXISTS (SELECT name FROM setting WHERE name = 'pdns_api_key') LIMIT 1;
EOF

#INSERT INTO "setting" VALUES(3,'pdns_version','4.1.1');
#INSERT INTO "user" VALUES(1,'admin','$2b$12$5MCtqsNx.lOeOONxsXNAfOmENU2BV2PfgZYodVVXFXUzSjfPYHjvq','Admin','Admin','admin@localhost.localdomain',NULL,NULL,1);

/usr/bin/gunicorn -t 120 --workers 4 --bind "0.0.0.0:${PDNSADMIN_PORT}" --log-level info app:app

