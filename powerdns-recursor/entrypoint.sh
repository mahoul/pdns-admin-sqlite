#!/bin/sh -x

[ -z $PDNS_R_MAX_CACHE_TTL ] && PDNS_R_MAX_CACHE_TTL=60
[ -z $PDNS_R_MAX_NEG_TTL ] && PDNS_R_MAX_NEG_TTL=60

cat <<-EOF >/etc/pdns/recursor-pdns.conf
	allow-from = 0.0.0.0/0
	dont-query=127.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 169.254.0.0/16, ::1/128, fc00::/7, fe80::/10, 0.0.0.0/8, 192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24, 240.0.0.0/4, ::/96, ::ffff:0:0/96, 100::/64, 2001:db8::/32
EOF

if [ -s /etc/pdns/forward-zones-input ]; then
	sed -e "s/powerdns/$(dig +short powerdns)/g" /etc/pdns/forward-zones-input > /etc/pdns/forward-zones
	echo "forward-zones-file=/etc/pdns/forward-zones" >> /etc/pdns/recursor-pdns.conf
fi

cat <<-EOF >>/etc/pdns/recursor-pdns.conf
	local-address = 0.0.0.0
	local-port = 5300
	max-cache-ttl = ${PDNS_R_MAX_CACHE_TTL}
	max-negative-ttl = ${PDNS_R_MAX_NEG_TTL}
EOF

pdns_recursor --config-name=pdns

