#!/usr/bin/env bash

source scripts/my-functions.sh

function cleanup() {
  docker rm -fv keycloak-clustered mssql
  docker network rm keycloak-net
}

echo
echo "+=========================="
echo "| Testing MSSQL connection "
echo "+=========================="

docker network create keycloak-net

echo
echo "+============================"
echo "| Running MSSQL on port 1433 "
echo "+============================"

docker run -d --rm --name mssql \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=my_Password \
  --network keycloak-net \
  mcr.microsoft.com/mssql/server:$MSSQL_VERSION

echo
wait_for_container_log "mssql" "Service Broker manager has started"

docker exec -i mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P my_Password -Q 'CREATE DATABASE keycloak'

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mssql                 "
echo "| KC_DB_URL_HOST: mssql        "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_URL_PROPERTIES=";trustServerCertificate=false;encrypt=false" \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
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
echo "| KC_DB: mssql                 "
echo "| KC_DB_URL_HOST: mssql        "
echo "| KC_DB_URL_PORT: 1443         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_PORT=1443 \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_URL_PROPERTIES=";trustServerCertificate=false;encrypt=false" \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
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

docker rm -fv keycloak-clustered mssql

echo
echo "+============================"
echo "| Running MSSQL on port 1443 "
echo "+============================"

docker run -d --rm --name mssql \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=my_Password \
  -e MSSQL_TCP_PORT=1443 \
  --network keycloak-net \
  mcr.microsoft.com/mssql/server:$MSSQL_VERSION

echo
wait_for_container_log "mssql" "Service Broker manager has started"

docker exec -i mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P my_Password -Q 'CREATE DATABASE keycloak'

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: mssql                 "
echo "| KC_DB_URL_HOST: mssql        "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_URL_PROPERTIES=";trustServerCertificate=false;encrypt=false" \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
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
echo "| KC_DB: mssql                 "
echo "| KC_DB_URL_HOST: mssql        "
echo "| KC_DB_URL_PORT: 1434         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_PORT=1443 \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_URL_PROPERTIES=";trustServerCertificate=false;encrypt=false" \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
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
echo "| MSSQL connection completed successfully! "
echo "+=========================================="
