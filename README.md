## keycloak-clustered

## Start Environment

#### (Optional) Build the docker image
```
docker build -t ivanfranchin/keycloak-clustered:development .
```

#### Create network
```
docker network create keycloak-net
```

#### Start [MySQL](https://hub.docker.com/_/mysql) container
```
docker run -d --rm \
--name mysql \
--hostname mysql \
--network keycloak-net \
-p 3306:3306 \
-e MYSQL_DATABASE=keycloak \
-e MYSQL_USER=keycloak \
-e MYSQL_PASSWORD=password \
-e MYSQL_ROOT_PASSWORD=root_password \
mysql:5.7.22
```

## Standalone Clustered Mode

#### Run _keycloak-standalone-1_
```
docker run -d --rm \
--name keycloak-standalone-1 \
--hostname keycloak-standalone-1 \
--network keycloak-net \
-p 8080:8080 \
-e KEYCLOAK_USER=admin \
-e KEYCLOAK_PASSWORD=admin \
-e JDBC_PARAMS=autoReconnect=true&useSSL=false&useUnicode=yes&characterEncoding=UTF-8&useLegacyDatetimeCode=false&serverTimezone=UTC \
ivanfranchin/keycloak-clustered:development
```

#### Run _keycloak-standalone-2_
```
docker run -d --rm \
--name keycloak-standalone-2 \
--hostname keycloak-standalone-2 \
--network keycloak-net \
-p 8081:8080 \
-e JDBC_PARAMS="autoReconnect=true&useSSL=false&useUnicode=yes&characterEncoding=UTF-8&useLegacyDatetimeCode=false&serverTimezone=UTC" \
ivanfranchin/keycloak-clustered:development
```