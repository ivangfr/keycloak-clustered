#!/usr/bin/env bash

source scripts/my-functions.sh

function cleanup() {
  docker rm -fv keycloak-clustered mysql
  docker network rm keycloak-net
}

echo
echo "+=========================="
echo "| Testing MySQL connection "
echo "+=========================="

docker network create keycloak-net

echo
echo "+============================"
echo "| Running MySQL on port 3306 "
echo "+============================"

docker run -d --rm --name mysql \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mysql:$MYSQL_VERSION

echo
wait_for_container_log "mysql" "port: 3306"

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mysql                 "
echo "| KC_DB_URL_HOST: mysql        "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mysql \
  -e KC_DB_URL_HOST=mysql \
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
echo "| KC_DB: mysql                 "
echo "| KC_DB_URL_HOST: mysql        "
echo "| KC_DB_URL_PORT: 3307         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mysql \
  -e KC_DB_URL_HOST=mysql \
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

docker rm -fv keycloak-clustered mysql

echo
echo "+============================"
echo "| Running MySQL on port 3307 "
echo "+============================"

docker run -d --rm --name mysql \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mysql:$MYSQL_VERSION --port=3307

echo
wait_for_container_log "mysql" "port: 3307"

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mysql                 "
echo "| KC_DB_URL_HOST: mysql        "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mysql \
  -e KC_DB_URL_HOST=mysql \
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
echo "| KC_DB: mysql                 "
echo "| KC_DB_URL_HOST: mysql        "
echo "| KC_DB_URL_PORT: 3307         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mysql \
  -e KC_DB_URL_HOST=mysql \
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
echo "+=========================================="
echo "| MySQL connection completed successfully! "
echo "+=========================================="
