#!/bin/bash
MYSQL_HOST=db
MYSQL_USER=root
MYSQL_PASSWORD=${DB_ENV_MYSQL_ROOT_PASSWORD}
MYSQL_DB=pdns

until nc -z db 3306; do
    echo "$(date) - waiting for mysql..."
    sleep 1
done

if mysql -u root -p${MYSQL_PASSWORD} --host=db "${MYSQL_DB}" >/dev/null 2>&1 </dev/null
then
	echo "Database ${MYSQL_DB} already exists"
else
	mysql -u root -p${MYSQL_PASSWORD} --host=db -e "CREATE DATABASE ${MYSQL_DB}"
	mysql -u root -p${MYSQL_PASSWORD} --host=db pdns < /pdns.sql
	mysql -u root -p${MYSQL_PASSWORD} --host=db pdns < /poweradmin.sql
	rm /pdns.sql /poweradmin.sql
fi

### PDNS
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf

### POWERADMIN
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /var/www/html/inc/config.inc.php

/usr/bin/supervisord
