#!/bin/bash

if [ -z ${PDNSCONF_GMYSQL_PASSWORD} ]
then
	PDNSCONF_GMYSQL_PASSWORD=${DB_ENV_MYSQL_PASSWORD}
fi

MYSQL_HOST=${PDNSCONF_GMYSQL_HOST}
MYSQL_PORT=${PDNSCONF_GMYSQL_PORT}
MYSQL_USER=${PDNSCONF_GMYSQL_USER}
MYSQL_PASSWORD=${PDNSCONF_GMYSQL_PASSWORD}
MYSQL_DB=${PDNSCONF_GMYSQL_DBNAME}
POWERADMIN_HOSTMASTER=${POWERADMIN_HOSTMASTER:-}
POWERADMIN_NS1=${POWERADMIN_NS1:-}
POWERADMIN_NS2=${POWERADMIN_NS2:-}

until nc -z ${MYSQL_HOST} ${MYSQL_PORT}; do
	echo "$(date) - waiting for mysql..."
	sleep 1
done

if mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} "${MYSQL_DB}" >/dev/null 2>&1 </dev/null
then
	echo "Database ${MYSQL_DB} already exists"
else
	mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} -e "CREATE DATABASE ${MYSQL_DB}"
fi

count=`mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_type='BASE TABLE' AND table_schema='${MYSQL_DB}';" | tail -1`
if [ "x$count" == "x0" ]
then
	mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${MYSQL_DB} < /pdns.sql
	mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${MYSQL_DB} < /poweradmin.sql
	rm /pdns.sql /poweradmin.sql
else
	echo "Database ${MYSQL_DB} is already populated"
fi

### PDNS
mkdir -p /etc/powerdns/pdns.d
cat /dev/null > /etc/powerdns/pdns.d/pdns.local.conf

PDNSVARS=`echo ${!PDNSCONF_*}`
for var in $PDNSVARS; do
  varname=`echo ${var#"PDNSCONF_"} | awk '{print tolower($0)}' | sed 's/_/-/g'`
  value=`echo ${!var} | sed 's/^$\(.*\)/\1/'`
  if [ ! -z ${!value} ]; then
    echo "$varname=${!value}" >> /etc/powerdns/pdns.d/pdns.local.conf
  else
    echo "$varname=$value" >> /etc/powerdns/pdns.d/pdns.local.conf
  fi
done

if [ ! -z $PDNSCONF_API_KEY ]; then
  cat >/etc/powerdns/pdns.d/api.conf <<EOF
api=yes
webserver=yes
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
EOF
fi

### POWERADMIN
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PORT}}/${MYSQL_PORT}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_HOSTMASTER}}/${POWERADMIN_HOSTMASTER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS1}}/${POWERADMIN_NS1}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS2}}/${POWERADMIN_NS2}/" /var/www/html/inc/config.inc.php

exec /usr/bin/supervisord
