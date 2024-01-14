# keycloak-clustered

**Keycloak-Clustered** extends `quay.io/keycloak/keycloak` official **Keycloak Docker image** by adding **JDBC_PING** discovery protocol

## Proof-of-Concepts & Articles

On [ivangfr.github.io](https://ivangfr.github.io), I have compiled my Proof-of-Concepts (PoCs) and articles. You can easily search for the technology you are interested in by using the filter. Who knows, perhaps I have already implemented a PoC or written an article about what you are looking for.

## Additional Readings

- \[**Medium**\] [**Keycloak Cluster using JDBC-PING for Distributed Caching**](https://medium.com/@ivangfr/keycloak-cluster-using-jdbc-ping-for-distributed-caching-8ba5c09cc206)
- \[**Medium**\] [**Keycloak Cluster Setup with Vagrant, Virtual Machines, and JDBC-PING for Distributed Caching**](https://medium.com/javarevisited/keycloak-cluster-setup-with-vagrant-virtual-machines-and-jdbc-ping-for-distributed-caching-bd09708219d1)
- \[**Medium**\] [**Keycloak Cluster Setup with Docker Compose and JDBC-PING for Distributed Caching**](https://medium.com/javarevisited/keycloak-cluster-setup-with-docker-compose-and-jdbc-ping-for-distributed-caching-3623fb6ee513)
- \[**Medium**\] [**Keycloak Cluster Setup with Docker Compose and UDP for Distributed Caching**](https://medium.com/javarevisited/keycloak-cluster-setup-with-docker-compose-and-udp-for-distributed-caching-9123be1de12d)

## Supported tags and respective Dockerfile links

- `23.0.4`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/23.0.4/Dockerfile))
- `23.0.3` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/23.0.3/Dockerfile))
- `23.0.2` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/23.0.2/Dockerfile))
- `23.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/23.0.1/Dockerfile))
- `23.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/23.0.0/Dockerfile))

## Author

Ivan Franchin ([**LinkedIn**](https://www.linkedin.com/in/ivanfranchin)) ([**Github**](https://github.com/ivangfr)) ([**Medium**](https://medium.com/@ivangfr)) ([**Twitter**](https://twitter.com/ivangfr))

## Environment Variables

Please, refer to the official **Keycloak** documentation at https://www.keycloak.org/server/all-config

## How to build locally a development Docker image

Navigate into one of the version folders and run the following command
```
docker build -t ivanfranchin/keycloak-clustered:latest .
```

## How to check if Keycloak instances are sharing user sessions

1. Open two different browsers, for instance `Chrome` and `Safari` or `Chrome` and `Incognito Chrome`.

2. In one access http://localhost:8080/admin/ and, in another, http://localhost:8081/admin/

3. Login with the following credentials
   ```
   username: admin
   password: admin
   ```

4. Once logged in
  - Click `Sessions` present on the menu on the left;
  - You should see that `admin` has two sessions.

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
  mysql:5.7.43
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
  ivanfranchin/keycloak-clustered:latest start-dev
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
  ivanfranchin/keycloak-clustered:latest start-dev
```

#### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

#### Check database

Access `MySQL monitor` terminal inside `mysql` Docker container
```
docker exec -it -e MYSQL_PWD=password mysql mysql -ukeycloak --database keycloak
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
  -e MARIADB_DATABASE=keycloak \
  -e MARIADB_USER=keycloak \
  -e MARIADB_PASSWORD=password \
  -e MARIADB_ROOT_PASSWORD=root_password \
  --network keycloak-net \
  mariadb:10.11.4
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
  ivanfranchin/keycloak-clustered:latest start-dev
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
  ivanfranchin/keycloak-clustered:latest start-dev
```

#### Testing

In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

#### Check database

Access `MariaDB monitor` terminal inside `mariadb` Docker container
```
docker exec -it mariadb mariadb -ukeycloak -ppassword --database keycloak
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
  postgres:15.4
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
  ivanfranchin/keycloak-clustered:latest start-dev
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
  ivanfranchin/keycloak-clustered:latest start-dev
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
  -e MSSQL_SA_PASSWORD=my_Password \
  --network keycloak-net \
  mcr.microsoft.com/mssql/server:2022-CU1-ubuntu-20.04
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
  -e KC_DB_URL_PROPERTIES=";trustServerCertificate=false;encrypt=false" \
  -e KC_DB_SCHEMA=myschema \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest start-dev
```

Finally, open another terminal and run `keycloak-clustered-2` Docker container
```
docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=mssql \
  -e KC_DB_URL_HOST=mssql \
  -e KC_DB_URL_DATABASE=keycloak \
  -e KC_DB_URL_PROPERTIES=";trustServerCertificate=false;encrypt=false" \
  -e KC_DB_SCHEMA=myschema \
  -e KC_DB_USERNAME=SA \
  -e KC_DB_PASSWORD=my_Password \
  -e KC_LOG_LEVEL=INFO,org.infinispan:DEBUG,org.jgroups:DEBUG \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest start-dev
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
  vagrant@vagrant:~$ docker exec -it -e MYSQL_PWD=password mysql mysql -ukeycloak --database keycloak
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

### Microsoft SQL Server

```
ERROR [org.jgroups.protocols.JDBC_PING] (keycloak-cache-init) JGRP000128: Error clearing table: com.microsoft.sqlserver.jdbc.SQLServerException: Invalid object name 'JGROUPSPING'.
	at com.microsoft.sqlserver.jdbc.SQLServerException.makeFromDatabaseError(SQLServerException.java:265)
	at com.microsoft.sqlserver.jdbc.SQLServerStatement.getNextResult(SQLServerStatement.java:1673)
	at com.microsoft.sqlserver.jdbc.SQLServerPreparedStatement.doExecutePreparedStatement(SQLServerPreparedStatement.java:620)
	at com.microsoft.sqlserver.jdbc.SQLServerPreparedStatement$PrepStmtExecCmd.doExecute(SQLServerPreparedStatement.java:540)
	at com.microsoft.sqlserver.jdbc.TDSCommand.execute(IOBuffer.java:7627)
	at com.microsoft.sqlserver.jdbc.SQLServerConnection.executeCommand(SQLServerConnection.java:3912)
	at com.microsoft.sqlserver.jdbc.SQLServerStatement.executeCommand(SQLServerStatement.java:268)
	at com.microsoft.sqlserver.jdbc.SQLServerStatement.executeStatement(SQLServerStatement.java:242)
	at com.microsoft.sqlserver.jdbc.SQLServerPreparedStatement.execute(SQLServerPreparedStatement.java:518)
	at org.jgroups.protocols.JDBC_PING.clearTable(JDBC_PING.java:362)
	at org.jgroups.protocols.JDBC_PING.removeAll(JDBC_PING.java:182)
	at org.jgroups.protocols.FILE_PING.handleView(FILE_PING.java:206)
	at org.jgroups.protocols.FILE_PING.down(FILE_PING.java:138)
	at org.jgroups.protocols.MERGE3.down(MERGE3.java:249)
	at org.jgroups.protocols.FD_SOCK2.down(FD_SOCK2.java:226)
	at org.jgroups.protocols.FailureDetection.down(FailureDetection.java:149)
	at org.jgroups.protocols.VERIFY_SUSPECT2.down(VERIFY_SUSPECT2.java:84)
	at org.jgroups.protocols.pbcast.NAKACK2.down(NAKACK2.java:619)
	at org.jgroups.protocols.UNICAST3.down(UNICAST3.java:611)
	at org.jgroups.protocols.pbcast.STABLE.down(STABLE.java:260)
	at org.jgroups.protocols.pbcast.GMS.installView(GMS.java:676)
	at org.jgroups.protocols.pbcast.ClientGmsImpl.becomeSingletonMember(ClientGmsImpl.java:251)
	at org.jgroups.protocols.pbcast.ClientGmsImpl.joinInternal(ClientGmsImpl.java:86)
	at org.jgroups.protocols.pbcast.ClientGmsImpl.join(ClientGmsImpl.java:37)
	at org.jgroups.protocols.pbcast.GMS.down(GMS.java:897)
	at org.jgroups.protocols.FlowControl.down(FlowControl.java:201)
	at org.jgroups.protocols.FlowControl.down(FlowControl.java:201)
	at org.jgroups.stack.Protocol.down(Protocol.java:283)
	at org.jgroups.protocols.FRAG2.down(FRAG2.java:102)
	at org.jgroups.stack.ProtocolStack.down(ProtocolStack.java:929)
	at org.jgroups.JChannel.down(JChannel.java:608)
	at org.jgroups.JChannel._connect(JChannel.java:808)
	at org.jgroups.JChannel.connect(JChannel.java:325)
	at org.jgroups.JChannel.connect(JChannel.java:316)
	at org.infinispan.remoting.transport.jgroups.JGroupsTransport.startJGroupsChannelIfNeeded(JGroupsTransport.java:621)
	at org.infinispan.remoting.transport.jgroups.JGroupsTransport.start(JGroupsTransport.java:490)
	at org.infinispan.remoting.transport.jgroups.CorePackageImpl$1.start(CorePackageImpl.java:42)
	at org.infinispan.remoting.transport.jgroups.CorePackageImpl$1.start(CorePackageImpl.java:27)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.invokeStart(BasicComponentRegistryImpl.java:617)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.doStartWrapper(BasicComponentRegistryImpl.java:608)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startWrapper(BasicComponentRegistryImpl.java:577)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl$ComponentWrapper.running(BasicComponentRegistryImpl.java:808)
	at org.infinispan.metrics.impl.MetricsCollector.start(MetricsCollector.java:78)
	at org.infinispan.metrics.impl.CorePackageImpl$1.start(CorePackageImpl.java:41)
	at org.infinispan.metrics.impl.CorePackageImpl$1.start(CorePackageImpl.java:34)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.invokeStart(BasicComponentRegistryImpl.java:617)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.doStartWrapper(BasicComponentRegistryImpl.java:608)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startWrapper(BasicComponentRegistryImpl.java:577)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl$ComponentWrapper.running(BasicComponentRegistryImpl.java:808)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startDependencies(BasicComponentRegistryImpl.java:635)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.doStartWrapper(BasicComponentRegistryImpl.java:599)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl.startWrapper(BasicComponentRegistryImpl.java:577)
	at org.infinispan.factories.impl.BasicComponentRegistryImpl$ComponentWrapper.running(BasicComponentRegistryImpl.java:808)
	at org.infinispan.factories.AbstractComponentRegistry.internalStart(AbstractComponentRegistry.java:357)
	at org.infinispan.factories.AbstractComponentRegistry.start(AbstractComponentRegistry.java:250)
	at org.infinispan.manager.DefaultCacheManager.internalStart(DefaultCacheManager.java:774)
	at org.infinispan.manager.DefaultCacheManager.start(DefaultCacheManager.java:742)
	at org.infinispan.manager.DefaultCacheManager.<init>(DefaultCacheManager.java:406)
	at org.keycloak.quarkus.runtime.storage.legacy.infinispan.CacheManagerFactory.startCacheManager(CacheManagerFactory.java:96)
	at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
	at java.base/java.lang.Thread.run(Thread.java:833)
```