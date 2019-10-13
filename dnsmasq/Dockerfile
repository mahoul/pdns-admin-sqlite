FROM alpine:3.10
MAINTAINER "Enrique Gil Palau <mahoul@gmail.com>"

RUN apk add --no-cache \
	bind-tools \
	dnsmasq

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 53
EXPOSE 53/udp

ENTRYPOINT ["/entrypoint.sh"]

