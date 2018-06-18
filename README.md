## keycloak-clustered

**keycloak-clustered** extends [`Keycloak docker image`](https://hub.docker.com/r/jboss/keycloak). It allows to run easily a cluster of Keycloak instances in [Standalone Clustered Mode](https://www.keycloak.org/docs/latest/server_installation/index.html#_standalone-ha-mode).

### Supported tags and respective `Dockerfile` links

- `4.0.0.Final`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/Dockerfile))

### Author

Ivan Franchin ([LinkedIn](https://www.linkedin.com/in/ivanfranchin))

## Note

**When we have instances of Keycloak running in different docker machines, they are NOT joining the infinispan cluster. [More about](https://www.keycloak.org/docs/latest/server_installation/index.html#troubleshooting-2)**

## Environment Variables

|Environment variable|Description|
|---|---|
|**DB_VENDOR**|`h2`, `postgres`, `mysql`, `mariadb`. If it is not specified the image will try to detect the DB vendor|
|**DB_ADDR**|Specify hostname of the database (optional)|
|**DB_PORT**|Specify port of the database (optional, default is DB vendor default port)|
|**DB_DATABASE**|Specify name of the database to use (optional, default is `keycloak`)|
|**DB_USERNAME**|Specify user to use to authenticate to the database (optional, default is `keycloak`)|
|**DB_PASSWORD**|Specify user's password to use to authenticate to the database (optional, default is `password`)|
|**DIST_CACHE_OWNERS** _(1)_|Specify number of distributed cache owners for handling user sessions (optional, default is `1`)|

_(1)_ For more information check [Replication and Failover](https://www.keycloak.org/docs/latest/server_installation/index.html#replication-and-failover) in Keycloak Documentation

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
-e DIST_CACHE_OWNERS=2 \
-e JDBC_PARAMS=useSSL=false \
ivanfranchin/keycloak-clustered:development
```

#### Run _keycloak-standalone-2_
```
docker run -d --rm \
--name keycloak-standalone-2 \
--hostname keycloak-standalone-2 \
--network keycloak-net \
-p 8081:8080 \
-e DIST_CACHE_OWNERS=2 \
-e JDBC_PARAMS=useSSL=false \
ivanfranchin/keycloak-clustered:development
```

### Keycloak Tutorial

You can find the more information from creating a Realm in Keycloak until connection this Realm to a LDAP service in: https://github.com/ivangfr/springboot-keycloak-openldap#configuring-keycloak

### Extras

If you want to integrate `Keycloak` with [`OpenLDAP`](https://www.openldap.org), bellow are the containers you must run. Please check https://github.com/ivangfr/springboot-keycloak-openldap#configuring-ldap for more information.

```
docker run -d --rm \
--name ldap-host \
--hostname ldap-host \
--network keycloak-net \
-p 389:389 \
-e LDAP_ORGANISATION="MyCompany Inc." \
-e LDAP_DOMAIN=mycompany.com \
osixia/openldap:1.2.1

docker run -d --rm \
--name phpldapadmin-service \
--hostname phpldapadmin-service \
--network keycloak-net \
-p 6443:443 \
-e PHPLDAPADMIN_LDAP_HOSTS=ldap-host \
osixia/phpldapadmin:0.7.1
```