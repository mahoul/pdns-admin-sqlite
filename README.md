# pdns-admin-sqlite
PowerDNS deployment using:

- dnsmasq as dns front cache
- powerdns-recursor as recursive DNS
- powerdns as authoritative server
- powerdns-admin as powerdns web frontend
- nginx-proxy (jwilder/nginx-proxy) as https proxy

PowerDNS and PowerDNS-Admin using using sqlite databases.

## Requisities

- docker
- docker-compose

## Quick-and-dirty run

```sh
$ sudo echo "127.0.0.2 pdns.localhost pda.localhost" >> /etc/hosts

$ sudo ifconfig lo:0 127.0.0.2

$ bash -x run-pdns-admin.sh

```

If docker-compose brings all the containers succesfully, you may have access 
to https://pdns.localhost to PowerDNS API and to https://pda.localhost for
PowerDNS-Admin.
 
## Persistent storage

| folder | contains |
|--------|----------|
|ssl-certs | ssl certificates and configs files for their generation |
|db-powerdns | PowerDNS DB |
|db-powerdns-admin | PowerDNS-Admin DB |


