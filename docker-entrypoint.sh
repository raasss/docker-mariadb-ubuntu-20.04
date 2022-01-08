#!/bin/bash

set -xe

# TODO: implement supervisord for running 3 tails and mariadb
tail -F /var/log/mysql/mysql.log >/dev/stdout &
tail -F  /var/log/mysql/error.log >/dev/stderr &
tail -F  /var/log/mysql/mariadb-slow.log >/dev/stdout &

for ENVVAR in $(env | grep -E '^MARIADB_SERVER_CONF_.+')
do
  ENVVAR_SECTION=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 1)
  ENVVAR_KEY=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 2)
  ENVVAR_VALUE=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 3-)
  crudini --verbose --set "/etc/mysql/mariadb.conf.d/50-server.cnf" "${ENVVAR_SECTION}" "${ENVVAR_KEY}" "${ENVVAR_VALUE}"
done

mysqld_safe &
MYSQLD_SAFE_PID=$!

echo -n "Waiting 1min for mysql to start"
for I in {0..5}; do
    if mysql -v --user=root --password="" -e "SELECT 1"; then
        break
    fi
    echo -n .
    sleep 1s
done

if [ "${I}" == "5" ]; then
    exit 1
fi

mysql -v -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
mysql -v -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'"
mysql -v -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}'"

MYSQLD_PID="$(cat /var/run/mysqld/mysqld.pid)"
kill -s TERM "${MYSQLD_PID}"

wait "${MYSQLD_SAFE_PID}"

mysqld_safe
