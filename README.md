PowerDNS Authoritative server and Poweradmin
===========
[![](https://badge.imagelayers.io/secns/pdns:latest.svg)](https://imagelayers.io/?images=secns/pdns:latest 'Get your own badge on imagelayers.io')

# Quickstart

```wget https://raw.githubusercontent.com/romracer/docker-pdns/master/docker-compose.yml && docker-compose up -d```

# Running

Just use this command to start the container. PowerDNS will listen on port 53/tcp, 53/udp and 8080/tcp.

```docker run --name pdns-master --link mysql:db -d -p 53:53/udp -p 53:53 -p 8080:80 secns/pdns:4.0.1```

Poweradmin Login:
``` admin / admin ```

# Configuration via Environment Variable

Any option from https://doc.powerdns.com/md/authoritative/settings/ can be set.
Just add the prefix "PDNSCONF\_" and replace any hyphens (-) with underscore (\_). Example: 

``` allow-axfr-ips ===> PDNSCONF_ALLOW_AXFR_IPS ```

Some common options to set:

- **PDNSCONF_ALLOW_AXFR_IPS**: restrict zonetransfers to originate from these IP addresses. Enter your slave IPs here. (Default: "127.0.0.1", Possible Values: "IPs comma seperated")
- **PDNSCONF_MASTER**: act as master (Default: "yes", Possible Values: "yes, no")
- **PDNSCONF_SLAVE**: act as slave (Default: "no", Possible Values: "yes, no")
- **PDNSCONF_CACHE_TTL**: Seconds to store packets in the PacketCache (Default: "20", Possible Values: "<integer>")
- **PDNSCONF_DISTRIBUTOR_THREADS**: Default number of Distributor (backend) threads to start (Default: "3", Possible Values: "<integer>")
- **PDNSCONF_RECURSIVE_CACHE_TTL**: Seconds to store packets in the PacketCache (Default: "10", Possible Values: "<integer>")
- **PDNSCONF_RECURSOR**: If recursion is desired, IP address of a recursing nameserver (Default: "no", Possible Values: "yes, no")
- **PDNSCONF_ALLOW_RECURSION**: List of subnets that are allowed to recurse (Default: "127.0.0.1", Possible Values: "<ipaddr>")

# Additional Poweradmin Environment Variables

- **POWERADMIN_HOSTMASTER**: default hostmaster (Default: "", Possible Values: "<email>")
- **POWERADMIN_NS1**: default Nameserver 1 (Default: "", Possible Values: "<domain>")
- **POWERADMIN_NS2**: default Nameserver 2 (Default: "", Possible Values: "<domain>")
