FROM alpine:3.10
MAINTAINER "Enrique Gil Palau <mahoul@gmail.com>"

RUN apk add --no-cache \
	bind-tools \
	pdns-recursor

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 5300
EXPOSE 5300/udp

ENTRYPOINT ["/entrypoint.sh"]

