# keycloak-clustered

**Keycloak-Clustered** extends `quay.io/keycloak/keycloak` official **Keycloak Docker image** by adding **JDBC_PING** discovery protocol

## Supported tags and respective Dockerfile links

- `17.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/keycloak-quarkus/17.0.1/Dockerfile))
- `17.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/keycloak-quarkus/17.0.0/Dockerfile))

## Author

Ivan Franchin ([LinkedIn](https://www.linkedin.com/in/ivanfranchin)) ([Github](https://github.com/ivangfr))

## Environment Variables

Please, refer to the official **Keycloak** documentation at https://www.keycloak.org/server/all-config

## How to build locally a development Docker image

Navigate into one oof the version folders and run the following command
```
docker build -t keycloak-clustered:development .
```

## How to check if Keycloak instances are sharing user sessions

1. Open two different browsers, for instance `Chrome` and `Safari` or `Chrome` and `Incognito Chrome`.

1. In one access `http://localhost:8080/admin/` and, in another, `http://localhost:8081/admin/`

1. Login with the following credentials
   ```
   username: admin
   password: admin
   ```

1. Once logged in
  - Click `Users` present on the menu on the left;
  - Click `View All` button. The `admin` will appear;
  - Click `admin`'s `Edit` button;
  - Finally, click `Sessions` tab. You should see that `admin` has two sessions.

## Running a Keycloak Cluster using JDBC_PING

### Prerequisites

[`Docker`](https://www.docker.com/)

### Using MySQL

#### Startup

Open a terminal and create a Docker network
```
docker network create keycloak-net
```

Run [MySQL](https://hub.docker.com/_/mysql) Docker container
```
docker run --rm --name mysql -p 3306:3306 \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mysql:5.7.37
```

Open another terminal and run `keycloak-clustered-1` Docker container
```
docker run --rm --name keycloak-clustered-1 -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mysql \
  -e KC_DB_URL_HOST=mysql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

Finally, open another terminal and run `keycloak-clustered-2` Docker container
```
docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mysql \
  -e KC_DB_URL_HOST=mysql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

#### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

#### Check database

Access `MySQL monitor` terminal inside `mysql` Docker container
```
docker exec -it mysql mysql -ukeycloak -ppassword --database keycloak
```

List tables
```
mysql> show tables;
```

Select entries in `JGROUPSPING` table
```
mysql> SELECT * FROM JGROUPSPING;
```

To exit `MySQL monitor` terminal type `exit`

#### Teardown

To stop `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

To stop `mysql` Docker container, press `Ctrl+\` in its terminal;

To remove Docker network, run in a terminal
```
docker network rm keycloak-net
```

### Using MariaDB

Open a terminal and create a Docker network
```
docker network create keycloak-net
```

Run [MariaDB](https://hub.docker.com/_/mariadb) Docker container
```
docker run --rm --name mariadb -p 3306:3306 \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mariadb:10.6.5
```

Open another terminal and run `keycloak-clustered-1` Docker container
```
docker run --rm --name keycloak-clustered-1 -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mariadb \
  -e KC_DB_URL_HOST=mariadb \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

Finally, open another terminal and run `keycloak-clustered-2` Docker container
```
docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mariadb \
  -e KC_DB_URL_HOST=mariadb \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

#### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

#### Check database

Access `MariaDB monitor` terminal inside `mariadb` Docker container
```
docker exec -it mariadb mysql -ukeycloak -ppassword --database keycloak
```

List tables
```
MariaDB [keycloak]> show tables;
```

Select entries in `JGROUPSPING` table
```
MariaDB [keycloak]> SELECT * FROM JGROUPSPING;
```

To exit `MariaDB monitor` terminal type `exit

#### Teardown

To stop `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

To stop `mariadb` Docker container, press `Ctrl+\` in its terminal;

To remove Docker network, run in a terminal
```
docker network rm keycloak-net
```

### Using Postgres

> **Warning**: It is not working! See [Issues](#issues) section 

#### Startup

Open a terminal and create a Docker network
```
docker network create keycloak-net
```

Run [Postgres](https://hub.docker.com/_/postgres) Docker container
```
docker run --rm --name postgres -p 5432:5432 \
  -e POSTGRES_DB=keycloak \
  -e POSTGRES_USER=keycloak \
  -e POSTGRES_PASSWORD=password \
  --network keycloak-net \
  postgres:14.2
```

Open another terminal and run `keycloak-clustered-1` Docker container
```
docker run --rm --name keycloak-clustered-1 -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL_HOST=postgres \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

Finally, open another terminal and run `keycloak-clustered-2` Docker container
```
docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL_HOST=postgres \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

#### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

#### Check database

Access `psql` terminal inside `postgres` Docker container
```
docker exec -it postgres psql -U keycloak
```

List tables in `myschema` schema
```
keycloak=# \dt myschema.*
```

Select entries in `JGROUPSPING` table
```
keycloak=# SELECT * FROM myschema.JGROUPSPING;
```

To exit `psql` terminal type `\q`

#### Teardown

To stop `postgres`, `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

To remove Docker network, run in a terminal
```
docker network rm keycloak-net
```

### Using Microsoft SQL Server

> **Warning**: It is not working! See [Issues](#issues) section

#### Startup

Open a terminal and create a Docker network
```
docker network create keycloak-net
```

Run [Microsoft SQL Server](https://hub.docker.com/_/microsoft-mssql-server) Docker container
```
docker run --rm --name mssql -p 1433:1433 \
  -e ACCEPT_EULA=Y \
  -e SA_PASSWORD=my_Password \
  --network keycloak-net \
  mcr.microsoft.com/mssql/server:2019-CU15-ubuntu-20.04
```

Open another terminal and run the following command to create `keycloak` database
```
docker exec -i mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P my_Password -Q 'CREATE DATABASE keycloak'
```

In a terminal, run `keycloak-clustered-1` Docker container
```
docker run --rm --name keycloak-clustered-1 -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

Finally, open another terminal and run `keycloak-clustered-2` Docker container
```
docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_SCHEMA=myschema \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:17.0.1 start-dev
```

#### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

#### Check database

Access `sqlcmd` terminal inside `mssql` Docker container
```
docker exec -it mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P my_Password
```

Select entries in `JGROUPSPING` table
```
1> select * from keycloak.myschema.JGROUPSPING
2> go
```

To exit `sqlcmd` terminal type `exit` or press `Ctrl+C`

#### Teardown

To stop `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

To remove Docker network, run in a terminal
```
docker network rm keycloak-net
```

## Running a Keycloak Cluster using JDBC_PING in Virtual Machines

### Prerequisites

[`VirtualBox`](https://www.virtualbox.org/) and [`Vagrant`](https://www.vagrantup.com/docs/installation)

### Startup

Open a terminal and make sure you are in `keycloak-clustered` root folder

You can edit `Vagrantfile` and set the database and/or the discovery protocol to be used

Start the virtual machines by running the command below
```
vagrant up
```

> **Mac Users**
>
> If you have an error like the one below
> ```
> The IP address configured for the host-only network is not within the
> allowed ranges. Please update the address used to be within the allowed
> ranges and run the command again.
>
>   Address: 10.0.0.1
>   Ranges: 123.456.78.0/21
>
> Valid ranges can be modified in the /etc/vbox/networks.conf file. For
> more information including valid format see:
>
>   https://www.virtualbox.org/manual/ch06.html#network_hostonly
> ```
>
> Create a new file at `/etc/vbox/networks.conf` on your Mac with content
> ```
> * 10.0.0.0/8 123.456.78.0/21
> * 2001::/64
> ```

Wait a bit until the virtual machines get started. It will take some time.

Once the execution of the command `vagrant up` finishes, we can check the state of all active Vagrant environments
```
vagrant status
```

Check `keycloak-clustered` docker logs in `keycloak1` virtual machine
```
vagrant ssh keycloak1
vagrant@vagrant:~$ docker logs keycloak-clustered -f
```
> **Note:** To get out of the logging view press `Ctrl+C` and to exit the virtual machine type `exit`

Check `keycloak-clustered` docker logs in `keycloak2` virtual machine
```
vagrant ssh keycloak2
vagrant@vagrant:~$ docker logs keycloak-clustered -f
```
> **Note:** To get out of the logging view press `Ctrl+C` and to exit the virtual machine type `exit`

Check databases if you are using `JDBC_PING`
```
vagrant ssh databases
```
> **Note:** To exit the virtual machine type `exit`

- MySQL
  ```
  vagrant@vagrant:~$ docker exec -it mysql mysql -ukeycloak -ppassword --database keycloak
  mysql> show tables;
  mysql> SELECT * FROM JGROUPSPING;
  ```
  > **Note:** To exit type `exit`

- MariaDB
  ```
  vagrant@vagrant:~$ docker exec -it mariadb mysql -ukeycloak -ppassword --database keycloak
  MariaDB [keycloak]> show tables;
  MariaDB [keycloak]> SELECT * FROM JGROUPSPING;
  ```
  > **Note:** To exit type `exit`

- Postgres
  ```
  vagrant@vagrant:~$ docker exec -it postgres psql -U keycloak
  keycloak=# \dt *.*
    
  -- `public` schema
  keycloak=# SELECT * FROM JGROUPSPING;
    
  -- in case the schema `myschema` was set
  keycloak=# SELECT * FROM myschema.JGROUPSPING;
  ```
  > **Note:** To exit type `\q`

### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

### Using another database

Edit `Vagrantfile` by setting to `DB_VENDOR` variable the database to be used

Reload Keycloak virtual machines by running
```
vagrant reload keycloak1 keycloak2 --provision
```

### Teardown

#### Suspend the machines

Suspending the virtual machines will stop them and save their current running state. For it run
```
vagrant suspend
```

To bring the virtual machines back up run
```
vagrant up
```

#### Halt the machines

Halting the virtual machines will gracefully shut down the guest operating system and power down the guest machine
```
vagrant halt
```

It preserves the contents of disk and allows to start it again by running
```
vagrant up
```

#### Destroy the machines

Destroying the virtual machine will remove all traces of the guest machine from your system. It'll stop the guest machine, power it down, and reclaim its disk space and RAM.
```
vagrant destroy -f
```

For a complete clean up, you can remove Vagrant box used in this section
```
vagrant box remove hashicorp/bionic64
```

## Issues

### Postgres

The following error is happening. Maybe, it's related to this [issue #10235](https://github.com/keycloak/keycloak/issues/10235)
```
ERROR [org.keycloak.quarkus.runtime.cli.ExecutionExceptionHandler] (main) ERROR: org.hibernate.exception.SQLGrammarException: could not extract ResultSet
ERROR [org.keycloak.quarkus.runtime.cli.ExecutionExceptionHandler] (main) ERROR: could not extract ResultSet
ERROR [org.keycloak.quarkus.runtime.cli.ExecutionExceptionHandler] (main) ERROR: ERROR: relation "migration_model" does not exist
```

### Microsoft SQL Server

The following exception is thrown. It looks like **Keycloak** cannot communicate with **Microsoft SQL Server** through port `1433`
```
ERROR [org.jgroups.protocols.JDBC_PING] (keycloak-cache-init) JGRP000115: Could not open connection to database: com.microsoft.sqlserver.jdbc.SQLServerException: The TCP/IP connection to the host mssql/keycloak, port 1433 has failed. Error: "mssql/keycloak. Verify the connection properties. Make sure that an instance of SQL Server is running on the host and accepting TCP/IP connections at the port. Make sure that TCP connections to the port are not blocked by a firewall.".
	at com.microsoft.sqlserver.jdbc.SQLServerException.makeFromDriverError(SQLServerException.java:234)
	at com.microsoft.sqlserver.jdbc.SQLServerException.ConvertConnectExceptionToSQLServerException(SQLServerException.java:285)
	at com.microsoft.sqlserver.jdbc.SocketFinder.findSocket(IOBuffer.java:2431)
	at com.microsoft.sqlserver.jdbc.TDSChannel.open(IOBuffer.java:656)
	at com.microsoft.sqlserver.jdbc.SQLServerConnection.connectHelper(SQLServerConnection.java:2440)
	at com.microsoft.sqlserver.jdbc.SQLServerConnection.login(SQLServerConnection.java:2103)
	at com.microsoft.sqlserver.jdbc.SQLServerConnection.connectInternal(SQLServerConnection.java:1950)
	at com.microsoft.sqlserver.jdbc.SQLServerConnection.connect(SQLServerConnection.java:1162)
	at com.microsoft.sqlserver.jdbc.SQLServerDriver.connect(SQLServerDriver.java:735)
	at java.sql/java.sql.DriverManager.getConnection(DriverManager.java:677)
	at java.sql/java.sql.DriverManager.getConnection(DriverManager.java:228)
	at org.jgroups.protocols.JDBC_PING.getConnection(JDBC_PING.java:290)
	at org.jgroups.protocols.JDBC_PING.attemptSchemaInitialization(JDBC_PING.java:250)
	at org.jgroups.protocols.JDBC_PING.init(JDBC_PING.java:111)
	at org.jgroups.stack.ProtocolStack.initProtocolStack(ProtocolStack.java:854)
	at org.jgroups.stack.ProtocolStack.init(ProtocolStack.java:842)
	at org.jgroups.JChannel.<init>(JChannel.java:164)
	at org.infinispan.remoting.transport.jgroups.EmbeddedJGroupsChannelConfigurator.createChannel(EmbeddedJGroupsChannelConfigurator.java:128)
	at org.infinispan.remoting.transport.jgroups.JGroupsTransport.channelFromConfigurator(JGroupsTransport.java:694)
	at org.infinispan.remoting.transport.jgroups.JGroupsTransport.buildChannel(JGroupsTransport.java:666)
	at org.infinispan.remoting.transport.jgroups.JGroupsTransport.initChannel(JGroupsTransport.java:478)
	at org.infinispan.remoting.transport.jgroups.JGroupsTransport.start(JGroupsTransport.java:463)
	at org.infinispan.remoting.transport.jgroups.CorePackageImpl$1.start(CorePackageImpl.java:41)
	at org.infinispan.remoting.transport.jgroups.CorePackageImpl$1.start(CorePackageImpl.java:27)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.invokeStart(BasicComponentRegistryImpl.java:617)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.doStartWrapper(BasicComponentRegistryImpl.java:608)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startWrapper(BasicComponentRegistryImpl.java:577)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.access$700(BasicComponentRegistryImpl.java:30)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl$ComponentWrapper.running(BasicComponentRegistryImpl.java:808)
	at org.infinispan.metrics.impl.MetricsCollector.start(MetricsCollector.java:70)
	at org.infinispan.metrics.impl.CorePackageImpl$1.start(CorePackageImpl.java:41)
	at org.infinispan.metrics.impl.CorePackageImpl$1.start(CorePackageImpl.java:34)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.invokeStart(BasicComponentRegistryImpl.java:617)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.doStartWrapper(BasicComponentRegistryImpl.java:608)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startWrapper(BasicComponentRegistryImpl.java:577)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.access$700(BasicComponentRegistryImpl.java:30)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl$ComponentWrapper.running(BasicComponentRegistryImpl.java:808)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startDependencies(BasicComponentRegistryImpl.java:635)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.doStartWrapper(BasicComponentRegistryImpl.java:599)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startWrapper(BasicComponentRegistryImpl.java:577)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.access$700(BasicComponentRegistryImpl.java:30)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl$ComponentWrapper.running(BasicComponentRegistryImpl.java:808)
	at org.infinispan.factories.AbstractComponentRegistry.internalStart(AbstractComponentRegistry.java:354)
	at org.infinispan.factories.AbstractComponentRegistry.start(AbstractComponentRegistry.java:250)
	at org.infinispan.manager.DefaultCacheManager.internalStart(DefaultCacheManager.java:752)
	at org.infinispan.manager.DefaultCacheManager.start(DefaultCacheManager.java:720)
	at org.infinispan.manager.DefaultCacheManager.<init>(DefaultCacheManager.java:401)
	at org.keycloak.quarkus.runtime.storage.infinispan.CacheManagerFactory.startCacheManager(CacheManagerFactory.java:72)
	at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
	at java.base/java.lang.Thread.run(Thread.java:829)
```