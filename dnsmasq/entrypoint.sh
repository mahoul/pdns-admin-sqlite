#!/bin/sh -x

cat <<-EOF >/etc/dnsmasq.d/pdns.conf
	cache-size = 100
	no-daemon
	no-resolv
	server = $(dig +short powerdns-recursor)#5300
EOF

dnsmasq

