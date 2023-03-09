#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Please specify KEYCLOAK_CLUSTERED_VERSION parameter."
  echo "Usage: $0 <version>"
  exit 1
fi

KEYCLOAK_CLUSTERED_VERSION=$1
MYSQL_VERSION=5.7.41
MARIADB_VERSION=10.9.5
POSTGRES_VERSION=15.2
MSSQL_VERSION=2022-CU1-ubuntu-20.04

source scripts/test-mysql-kc-db-connection.sh
source scripts/test-mariadb-kc-db-connection.sh
source scripts/test-postgres-kc-db-connection.sh
# -- Unable to run Keycloak Clustered with MSSQL, see issue in README
#source scripts/test-mssql-kc-db-connection.sh

echo
echo "+##############################################"
echo "| All connection tests completed successfully! "
echo "+##############################################"
