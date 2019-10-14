FROM alpine:3.10
MAINTAINER "Enrique Gil Palau <mahoul@gmail.com>"

RUN apk add --no-cache \
	openssl \
	shadow && \
	addgroup ssl-user && \
	adduser -G ssl-user -H -D -s /bin/sh -h /tmp ssl-user 

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

