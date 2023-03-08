#!/usr/bin/env bash

source scripts/my-functions.sh

function cleanup() {
  docker rm -fv keycloak-clustered mariadb
  docker network rm keycloak-net
}

echo
echo "+============================"
echo "| Testing MariaDB connection "
echo "+============================"

docker network create keycloak-net

echo
echo "+=============================="
echo "| Running MariaDB on port 3306 "
echo "+=============================="

docker run -d --rm --name mariadb \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mariadb:$MARIADB_VERSION

echo
wait_for_container_log "mariadb" "port: 3306"

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mariadb               "
echo "| KC_DB_URL_HOST: mariadb      "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mariadb \
  -e KC_DB_URL_HOST=mariadb \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest start-dev

echo
wait_for_container_log "keycloak-clustered" "Running the server in development mode"
if [ $? -ne 0 ]; then
  test_fail
  cleanup
  exit 1
fi

docker rm -fv keycloak-clustered

test_ok

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mariadb               "
echo "| KC_DB_URL_HOST: mariadb      "
echo "| KC_DB_URL_PORT: 3307         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mariadb \
  -e KC_DB_URL_HOST=mariadb \
  -e KC_DB_URL_PORT=3307 \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest start-dev

echo
wait_for_container_log "keycloak-clustered" "Connection refused"
if [ $? -ne 0 ]; then
  test_fail
  cleanup
  exit 1
fi

test_ok

docker rm -fv keycloak-clustered mariadb

echo
echo "+=============================="
echo "| Running MariaDB on port 3307 "
echo "+=============================="

docker run -d --rm --name mariadb \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mariadb:$MARIADB_VERSION --port=3307

echo
wait_for_container_log "mariadb" "port: 3307"

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mariadb               "
echo "| KC_DB_URL_HOST: mariadb      "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mariadb \
  -e KC_DB_URL_HOST=mariadb \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest start-dev

echo
wait_for_container_log "keycloak-clustered" "Connection refused"
if [ $? -ne 0 ]; then
  test_fail
  cleanup
  exit 1
fi

test_ok

docker rm -fv keycloak-clustered

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mariadb               "
echo "| KC_DB_URL_HOST: mariadb      "
echo "| KC_DB_URL_PORT: 3307         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mariadb \
  -e KC_DB_URL_HOST=mariadb \
  -e KC_DB_URL_PORT=3307 \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest start-dev

echo
wait_for_container_log "keycloak-clustered" "Running the server in development mode"
if [ $? -ne 0 ]; then
  test_fail
  cleanup
  exit 1
fi

test_ok

cleanup

echo
echo "+============================================"
echo "| MariaDB connection completed successfully! "
echo "+============================================"
