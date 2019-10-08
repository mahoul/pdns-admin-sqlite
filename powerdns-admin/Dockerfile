FROM aescanero/powerdns-admin
MAINTAINER "Enrique Gil <mahoul@gmail.com>"

RUN apk add --no-cache sqlite

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 9191
ENTRYPOINT ["/entrypoint.sh"]
