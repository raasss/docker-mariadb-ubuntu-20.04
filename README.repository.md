**Maintained by**: [raasss](https://github.com/raasss/)


# Quick reference

-	Issues can be filed at [GitHub Issues](https://github.com/raasss/docker-mariadb-ubuntu-20.04/issues).

-	Supported architectures are: `linux/amd64`, `linux/arm/v7`, `linux/arm64` 

-	Source of this content can be found at [README.docker.io.md](https://github.com/raasss/docker-mariadb-ubuntu-20.04/blob/main/README.docker.io.md)

# Introduction

MariaDB Server is one of the most popular open source relational databases. It’s made by the original developers of MySQL and guaranteed to stay open source. It is part of most cloud offerings and the default in most Linux distributions. ([more info](https://mariadb.org/documentation/))

# Quickstart guide

Starting a mariadb instance with the latest version is simple via [`docker-compose`](https://github.com/docker/compose). If you don't have docker-compose tool installed, please go [here](https://docs.docker.com/compose/install/) and follow instractions.

Example `docker-compose.yml` for `mariadb`:

```yaml
version: '3.7'

networks:
  private:
    driver: bridge

services:
  mariadb:
    image: raasss/mariadb-ubuntu-20.04:latest
    networks:
      - private
    ports:
      - "3306"
    environment:
      - MARIADB_SERVER_CONF_1=mysqld:key_buffer_size:16M
      - MARIADB_SERVER_CONF_2=mysqld:general_log:0
      - MARIADB_SERVER_CONF_2=mysqld:slow_query_log:1
      - MARIADB_SERVER_CONF_2=mysqld:long_query_time:2
      - MARIADB_SERVER_CONF_2=mysqld:log_slow_rate_limit:1
      - MARIADB_SERVER_CONF_2=mysqld:log_slow_verbosity:query_plan,explain,innodb
      - MARIADB_SERVER_CONF_2=mysqld:log_queries_not_using_indexes:1
      - MARIADB_SERVER_CONF_2=mysqld:log_slow_admin_statements:1
      - MARIADB_SERVER_CONF_2=mysqld:character-set-server:utf8mb4
```

In your current working directory create `docker-compose.yml` file.

Run docker-compose and services should be up soon:

```console
$ docker-compose up -d
```

We can find port where mariadb service listen for connections like this:

```console
$ docker-compose port mariadb 3306
0.0.0.0:49154
```

In this example we can configure any mariadb client with host `0.0.0.0:49154`.

# Advance guide

## Container shell access

The `docker-compose exec` command allows you to run commands inside a Docker container.

The following command line will give you a bash shell inside your `mariadb` container as root:

```console
$ docker-compose exec mariadb bash
```

## Access logs

The log is available through Docker's container log:

```console
$ docker-compose logs mariadb -f
```

You can omit `-f` if you don't want to tail logs in realtime.

## Customizing via environment variables

Customization of `/etc/mysql/mariadb.conf.d/50-server.cnf` file in docker image is implemented.

This file is standard configuration files in INI format. Every INI file is consisted of `<section>` and `<key> = <value>` pairs.

This is how trimmed version of `php.ini` file looks like:

```ini
[server]

# this is only for the mysqld standalone daemon
[mysqld]

#
# * Fine Tuning
#
key_buffer_size		= 16M
max_allowed_packet	= 16M

#
# * Query Cache Configuration
#
query_cache_limit	= 1M
query_cache_size        = 16M

#
# * Logging and Replication
#
# Both location gets rotated by the cronjob.
# Be aware that this log type is a performance killer.
# As of 5.1 you can enable the log at runtime!
general_log             = 0

#
# Error log - should be very few entries.
#
log_warnings = 4
#
# Enable the slow query log to see queries with especially long duration
slow_query_log = 1
long_query_time = 2
log_slow_rate_limit	= 1
log_slow_verbosity = query_plan,explain,innodb
log_queries_not_using_indexes = 1
log_slow_admin_statements = 1

#
# * Character sets
#
# MySQL/MariaDB default is Latin1, but in Debian we rather default to the full
# utf8 4-byte character set. See also client.cnf
#
character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci

# this is only for embedded server
[embedded]

# This group is only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]

# This group is only read by MariaDB-10.0 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
[mariadb-10.0]
```

Here we can see 3 sections: `server`, `mysqld` , `embedded` , `mariadb` and `mariadb-10.0`. And multiple `key=value` pairs:

- `key_buffer_size = 16M`
- `slow_query_log = 1`
- `character-set-server = utf8mb4`

To configure files above you need to add environment variables in format `MARIADB_SERVER_CONF_*`.

Value of these environment variables need to be in format `<section>:<key>:<value>` as can be found in example `docker-compose.yml` file above.

## Pull service images
```console
docker-compose pull
```

## Backup database inside docker to local filesystem
```console
docker-compose exec -u root mariadb mysqldump --add-drop-database --add-drop-table --single-transaction --verbose mydatabase > mydatabase.sql
```

## Restore database from local filesystem to docker
```console
cat mydatabase.sql | docker-compose exec -T -u root mariadb mysql mydatabase
```

## Start services
```console
docker-compose start
```

## List containers
```console
docker-compose ps
```

## Create and start containers
```console
docker-compose up -d
```

## Stop services
```console
docker-compose stop
```

## Stop and remove containers, networks, images, and volumes
```console
docker-compose down --volumes --remove-orphans
```
