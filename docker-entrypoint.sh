#!/bin/bash

set -xe

tail -F /var/log/mysql/mysql.log >/dev/stdout &
tail -F  /var/log/mysql/error.log >/dev/stderr &
tail -F  /var/log/mysql/mariadb-slow.log >/dev/stdout &

sed -i -e "s/^log_warnings\s.*$/log_warnings = ${MYSQL_SERVER_LOG_WARNINGS}/g" /etc/mysql/mariadb.conf.d/50-server.cnf

sed -i -e "s/^general_log\s.*$/general_log = ${MYSQL_SERVER_GENERAL_LOG}/g" /etc/mysql/mariadb.conf.d/50-server.cnf

sed -i -e "s/^slow_query_log\s.*$/slow_query_log = ${MYSQL_SERVER_SLOW_QUERY_LOG}/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -e "s/^long_query_time\s.*$/long_query_time = ${MYSQL_SERVER_LONG_QUERY_TIME}/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -e "s/^log_slow_rate_limit\s.*$/log_slow_rate_limit = ${MYSQL_SERVER_LOG_SLOW_RATE_LIMIT}/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -e "s/^log_slow_verbosity\s.*$/log_slow_verbosity = ${MYSQL_SERVER_LOG_SLOW_VERBOSITY}/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -e "s/^log_queries_not_using_indexes\s.*$/log_queries_not_using_indexes = ${MYSQL_SERVER_LOG_QUERIES_NOT_USING_INDEXES}/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -e "s/^log_slow_admin_statements\s.*$/log_slow_admin_statements = ${MYSQL_SERVER_LOG_SLOW_ADMIN_STATEMENTS}/g" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i -e "s/^log_slow_filter\s.*$/log_slow_filter = ${MYSQL_SERVER_LOG_SLOW_FILTER}/g" /etc/mysql/mariadb.conf.d/50-server.cnf

# DOCKER_RUN_AS_GID=$(stat -c '%g' /var/lib/mysql)
# DOCKER_RUN_AS_UID=$(stat -c '%u' /var/lib/mysql)
# groupmod -g ${DOCKER_RUN_AS_GID} mysql
# usermod -u ${DOCKER_RUN_AS_UID} -g ${DOCKER_RUN_AS_GID} mysql
# chown -vR mysql /var/log/mysql

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

MYSQLD_PID="$(cat /var/run/mysqld/mysqld.pid)"
kill -s TERM "${MYSQLD_PID}"

wait "${MYSQLD_SAFE_PID}"

mysqld_safe
