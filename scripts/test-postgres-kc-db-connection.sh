#!/usr/bin/env bash

source scripts/my-functions.sh

function cleanup() {
  docker rm -fv keycloak-clustered postgres
  docker network rm keycloak-net
}

echo
echo "+============================="
echo "| Testing Postgres connection "
echo "+============================="

docker network create keycloak-net

echo
echo "+==============================="
echo "| Running Postgres on port 5432 "
echo "+==============================="

docker run -d --rm --name postgres \
  -e POSTGRES_DB=keycloak \
  -e POSTGRES_USER=keycloak \
  -e POSTGRES_PASSWORD=password \
  --network keycloak-net \
  postgres:$POSTGRES_VERSION

echo
wait_for_container_log "postgres" "port 5432"

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: postgres              "
echo "| KC_DB_URL_HOST: postgres     "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL_HOST=postgres \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
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
echo "| KC_DB: postgres              "
echo "| KC_DB_URL_HOST: postgres     "
echo "| KC_DB_URL_PORT: 5433         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL_HOST=postgres \
  -e KC_DB_URL_PORT=5433 \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
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

docker rm -fv keycloak-clustered postgres

echo
echo "+==============================="
echo "| Running Postgres on port 5433 "
echo "+==============================="

docker run -d --rm --name postgres \
  -e POSTGRES_DB=keycloak \
  -e POSTGRES_USER=keycloak \
  -e POSTGRES_PASSWORD=password \
  --network keycloak-net \
  postgres:$POSTGRES_VERSION --port=5433

echo
wait_for_container_log "postgres" "port 5433"

echo
echo "+------------------------------"
echo "| Running Keycloak             "
echo "+------------------------------"
echo "| KC_DB: postgres              "
echo "| KC_DB_URL_HOST: postgres     "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL_HOST=postgres \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
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
echo "| KC_DB: postgres              "
echo "| KC_DB_URL_HOST: postgres     "
echo "| KC_DB_URL_PORT: 5433         "
echo "| KC_DB_URL_DATABASE: keycloak "
echo "+------------------------------"

docker run -d --rm --name keycloak-clustered \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL_HOST=postgres \
  -e KC_DB_URL_PORT=5433 \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
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
echo "+============================================="
echo "| Postgres connection completed successfully! "
echo "+============================================="
