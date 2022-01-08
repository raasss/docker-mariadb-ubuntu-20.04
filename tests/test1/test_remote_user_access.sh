docker-compose exec mariadb-client bash -c 'mysql -v --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --host="mariadb-server" --database="${MYSQL_DATABASE}" -e "SELECT 1"'
