FROM ubuntu:20.04

ENV MYSQL_DATABASE="dbname1"
ENV MYSQL_USER="dbuser1"
ENV MYSQL_PASSWORD="dbuser1pass"

RUN set -e; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y --no-install-recommends \
      tini \
      crudini \
      mariadb-server-10.3=1:10.3.22-1ubuntu1 \
      mariadb-client-10.3=1:10.3.22-1ubuntu1; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rvf /var/lib/apt/lists/*

RUN set -e; \
    mkdir -v /var/run/mysqld; \
    chown -v -R mysql:mysql /var/run/mysqld

# ENV MYSQL_SERVER_LOG_WARNINGS="4"
# ENV MYSQL_SERVER_GENERAL_LOG="0"
# ENV MYSQL_SERVER_SLOW_QUERY_LOG="1"
# ENV MYSQL_SERVER_LONG_QUERY_TIME="2"
# ENV MYSQL_SERVER_LOG_SLOW_RATE_LIMIT="1"
# ENV MYSQL_SERVER_LOG_SLOW_VERBOSITY="query_plan,explain,innodb"
# ENV MYSQL_SERVER_LOG_QUERIES_NOT_USING_INDEXES="1"
# ENV MYSQL_SERVER_LOG_SLOW_ADMIN_STATEMENTS="1"
# ENV MYSQL_SERVER_LOG_SLOW_FILTER=""

VOLUME [ "/var/lib/mysql" ]

EXPOSE 3306

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod -v 0644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod -v 0755 /docker-entrypoint.sh

ENTRYPOINT ["tini", "--"]
CMD ["/docker-entrypoint.sh"]
