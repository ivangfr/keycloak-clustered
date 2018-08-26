## keycloak-clustered

**keycloak-clustered** extends [`Keycloak Oficial Docker Image`](https://hub.docker.com/r/jboss/keycloak). It allows to run easily a cluster of [Keycloak](https://www.keycloak.org) instances.

### Supported tags and respective `Dockerfile` links

- `4.0.0.Final`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/Dockerfile))

### Author

Ivan Franchin ([LinkedIn](https://www.linkedin.com/in/ivanfranchin))

## Environment Variables

|Environment variable|Description|
|---|---|
|**DB_VENDOR**|`h2`, `postgres`, `mysql`, `mariadb`. If it is not specified the image will try to detect the DB vendor|
|**DB_ADDR**|Specify hostname of the database (optional)|
|**DB_PORT**|Specify port of the database (optional, default is DB vendor default port)|
|**DB_DATABASE**|Specify name of the database to use (optional, default is `keycloak`)|
|**DB_USERNAME**|Specify user to use to authenticate to the database (optional, default is `keycloak`)|
|**DB_PASSWORD**|Specify user's password to use to authenticate to the database (optional, default is `password`)|
|**DIST_CACHE_OWNERS** _(1)_|Specify number of distributed cache owners for handling user sessions (optional, default is `2`)|

_(1)_ For more information check [Replication and Failover](https://www.keycloak.org/docs/latest/server_installation/index.html#replication-and-failover) in Keycloak Documentation

## JDBC_PING

This docker image uses the discovery protocol [`JDBC_PING`](https://developer.jboss.org/wiki/JDBCPING) to find `keycloak-clustered` instances in a network. The discovery protocol simply uses a single table in `keycloak` database called `JGROUPSPING`. As soon as a `keycloak-clustered` instance starts, a record referencing to it is inserted in `JGROUPSPING` table. It is through this table that the instances `ping` each other.

## Start Environment

#### Build the docker image
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

#### Run _keycloak-clustered-1_
```
docker run -d --rm \
--name keycloak-clustered-1 \
--hostname keycloak-clustered-1 \
--network keycloak-net \
-p 8080:8080 \
-e KEYCLOAK_USER=admin \
-e KEYCLOAK_PASSWORD=admin \
-e JDBC_PARAMS=useSSL=false \
ivanfranchin/keycloak-clustered:development
```

#### Run _keycloak-clustered-2_
```
docker run -d --rm \
--name keycloak-clustered-2 \
--hostname keycloak-clustered-2 \
--network keycloak-net \
-p 8081:8080 \
-e JDBC_PARAMS=useSSL=false \
ivanfranchin/keycloak-clustered:development
```

#### Check records in _JGROUPSPING_ table

- Run `docker exec` on the `mysql` running container
```
docker exec -it mysql bash -c 'mysql -ukeycloak -ppassword'
```

- Inside `MySQL` run the following `select`
```
select * from keycloak.JGROUPSPING;
```

### Keycloak Tutorial

You can find more information about configuring Keycloak in https://github.com/ivangfr/springboot-keycloak-openldap#configuring-keycloak. In this link, it is explained since basic stuffs like to create a Realm or an user, until more complex ones like how to connect to a LDAP service.

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