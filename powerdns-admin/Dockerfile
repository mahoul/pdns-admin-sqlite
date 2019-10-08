FROM aescanero/powerdns-admin
MAINTAINER "Enrique Gil <mahoul@gmail.com>"

RUN apk add --no-cache shadow sqlite && \
    addgroup pdnsadmin && \
    adduser -G pdnsadmin -H -D -s /bin/sh -h /tmp pdnsadmin && \
    mkdir /db && \
    chown -R pdnsadmin:pdnsadmin /opt/pdnsadmin /db

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 9191
ENTRYPOINT ["/entrypoint.sh"]
