FROM alpine:3.10
MAINTAINER "Enrique Gil Palau <mahoul@gmail.com>"

RUN apk add --no-cache \
	pdns-backend-sqlite3 \
	pdns-doc \
	shadow \
	sqlite && \
    mkdir /db /var/run/pdns && \
    chown -R pdns:pdns /etc/pdns /db /var/run/pdns
    
ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 53
EXPOSE 53/udp
EXPOSE 8081

ENTRYPOINT ["/entrypoint.sh"]

