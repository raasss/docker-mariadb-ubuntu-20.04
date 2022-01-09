#!/usr/bin/env bash

set -u

cd "$(dirname $0)"

RED='\033[0;31m' # red collor
GREEN='\033[0;32m' # green collor
NC='\033[0m' # no Color

RESULTS=""

for TESTDIR in $(ls -d test*); do
    cd $TESTDIR
    cp -f ../../50-server.cnf .
    cp -f ../../docker-entrypoint.sh .
    cp -f ../../Dockerfile .

    docker-compose pull
    docker-compose build
    docker-compose up -d
    DOCKER_HOST_URL="http://$(docker-compose port mariadb-server 3306)"

    while true; do
        if docker-compose exec mariadb-server bash -c 'mysql -v --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --host="127.0.0.1" --database="${MYSQL_DATABASE}" -e "SELECT 1"'; then
            break
        else
            sleep 1s;
        fi
    done

    for TESTFILE in $(ls -1 test_*.sh); do
        source ${TESTFILE}
        if [ "$?" == 0 ]
        then
            echo -e ">>> ${TESTDIR}/${TESTFILE} ... ${GREEN}PASS${NC}"
            RESULTS="${RESULTS}${TESTDIR}/${TESTFILE} ... ${GREEN}PASS${NC}\n"
        else
            echo -e ">>> ${TESTDIR}/${TESTFILE} ... ${RED}FAIL${NC}"
            RESULTS="${RESULTS}${TESTDIR}/${TESTFILE} ... ${RED}FAIL${NC}\n"
        fi
    done
    # # Clean test environment
    docker-compose logs
    docker-compose stop
    docker-compose down
    cd ..
done

echo
echo "Test results:"
echo
echo -e "${RESULTS}"
echo
