#!/bin/bash

set -xe

tail -F /var/log/mysql/mysql.log >/dev/stdout &
tail -F  /var/log/mysql/error.log >/dev/stderr &
tail -F  /var/log/mysql/mariadb-slow.log >/dev/stdout &

# customize mariadb conf file in runtime from environment variables

for ENVVAR in $(env | grep -E '^MARIADB_SERVER_CONF_.+')
do
  ENVVAR_SECTION=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 1)
  ENVVAR_KEY=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 2)
  ENVVAR_VALUE=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 3-)
  crudini --verbose --set "/etc/mysql/mariadb.conf.d/50-server.cnf" "${ENVVAR_SECTION}" "${ENVVAR_KEY}" "${ENVVAR_VALUE}"
done

# print mysqld startup defaults for easy check by user of this docker image

mysqld --print-defaults

# start mysqld

mysqld_safe &

# wait 60 seconds for mysqld to become operational

for I in {0..59}; do
    if mysql -v --user=root --password="" -e "SELECT 1"; then
        break
    fi
    sleep 1s
done

# exit with error code 1 if mysqld didn't became operational after 60 seconds

if [ "${I}" == "59" ]; then
    exit 1
fi

# configure database, user and access from environment variables

mysql -v -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
mysql -v -e "CREATE USER IF NOT EXISTS ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'"
mysql -v -e "CREATE USER IF NOT EXISTS ${MYSQL_USER}@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}'"
mysql -v -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@'%'"
mysql -v -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO ${MYSQL_USER}@'localhost'"
mysql -v -e "FLUSH PRIVILEGES"

# wait for any subprocess to fail and get it's exit code

set +e
wait -n
set -e

ERROR_CODE=$?

# gracefully shutdown mysql if it is working

if mysql -v -e "SELECT 1"; then
    mysqladmin shutdown || true
fi

# exit bash with fail subprocess exit code

exit ${ERROR_CODE}
