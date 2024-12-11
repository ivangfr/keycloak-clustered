# keycloak-clustered

**Keycloak-Clustered** extends `quay.io/keycloak/keycloak` official **Keycloak Docker image** by adding **JDBC_PING** discovery protocol

## Proof-of-Concepts & Articles

On [ivangfr.github.io](https://ivangfr.github.io), I have compiled my Proof-of-Concepts (PoCs) and articles. You can easily search for the technology you are interested in by using the filter. Who knows, perhaps I have already implemented a PoC or written an article about what you are looking for.

## Additional Readings

- \[**Medium**\] [**Keycloak Cluster using JDBC-PING for Distributed Caching**](https://medium.com/@ivangfr/keycloak-cluster-using-jdbc-ping-for-distributed-caching-8ba5c09cc206)
- \[**Medium**\] [**Keycloak Cluster Setup with Vagrant, Virtual Machines, and JDBC-PING for Distributed Caching**](https://medium.com/@ivangfr/keycloak-cluster-setup-with-vagrant-virtual-machines-and-jdbc-ping-for-distributed-caching-bd09708219d1)
- \[**Medium**\] [**Keycloak Cluster Setup with Docker Compose and JDBC-PING for Distributed Caching**](https://medium.com/@ivangfr/keycloak-cluster-setup-with-docker-compose-and-jdbc-ping-for-distributed-caching-3623fb6ee513)
- \[**Medium**\] [**Keycloak Cluster Setup with Docker Compose and UDP for Distributed Caching**](https://medium.com/@ivangfr/keycloak-cluster-setup-with-docker-compose-and-udp-for-distributed-caching-9123be1de12d)

## Supported tags and respective Dockerfile links

- `26.0.7`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.7/Dockerfile))
- `26.0.6` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.6/Dockerfile))
- `26.0.5` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.5/Dockerfile))
- `26.0.4` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.4/Dockerfile))
- `26.0.2` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.2/Dockerfile))
- `26.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.1/Dockerfile))
- `26.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/26.0.0/Dockerfile))
- `25.0.6` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/25.0.6/Dockerfile))
- `25.0.5` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/25.0.5/Dockerfile))
- `25.0.4` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/25.0.4/Dockerfile))
- `25.0.2` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/25.0.2/Dockerfile))
- `25.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/25.0.1/Dockerfile))
- `25.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/25.0.0/Dockerfile))

## Author

Ivan Franchin ([**LinkedIn**](https://www.linkedin.com/in/ivanfranchin)) ([**Github**](https://github.com/ivangfr)) ([**Medium**](https://medium.com/@ivangfr)) ([**X**](https://x.com/ivangfr))

## Environment Variables

Please, refer to the official **Keycloak** documentation at https://www.keycloak.org/server/all-config

## How to build locally a development Docker image

Navigate into one of the version folders and run the following command
```
docker build -t ivanfranchin/keycloak-clustered:latest .
```

## How to check if Keycloak instances are sharing user sessions

1. Open two different browsers, for instance `Chrome` and `Safari` or `Chrome` and `Incognito Chrome`.

2. In one access http://localhost:8080 and, in another, http://localhost:8081

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
  mysql:9.1.0
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
  mariadb:10.11.10
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
  postgres:17.2
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
  mcr.microsoft.com/mssql/server:2022-CU11-ubuntu-22.04
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

[`VirtualBox`](https://www.virtualbox.org/) and [`Vagrant`](https://developer.hashicorp.com/vagrant/docs/installation)

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
WARN  [com.arjuna.ats.jta] (main) ARJUNA016061: TransactionImple.enlistResource - XAResource.start returned: XAException.XAER_RMERR for < formatId=131077, gtrid_length=35, bqual_length=36, tx_uid=0:ffffac160003:a743:65a52f11:0, node_name=quarkus, branch_uid=0:ffffac160003:a743:65a52f11:3f, subordinatenodename=null, eis_name=0 >: javax.transaction.xa.XAException: com.microsoft.sqlserver.jdbc.SQLServerException: Failed to create the XA control connection. Error: "The connection is closed."
	at com.microsoft.sqlserver.jdbc.SQLServerXAResource.DTC_XA_Interface(SQLServerXAResource.java:757)
	at com.microsoft.sqlserver.jdbc.SQLServerXAResource.start(SQLServerXAResource.java:791)
	at io.agroal.narayana.BaseXAResource.start(BaseXAResource.java:150)
	at com.arjuna.ats.internal.jta.transaction.arjunacore.TransactionImple.enlistResource(TransactionImple.java:661)
	at com.arjuna.ats.internal.jta.transaction.arjunacore.TransactionImple.enlistResource(TransactionImple.java:422)
	at io.agroal.narayana.NarayanaTransactionIntegration.associate(NarayanaTransactionIntegration.java:93)
	at io.agroal.pool.ConnectionPool.getConnection(ConnectionPool.java:252)
	at io.agroal.pool.DataSource.getConnection(DataSource.java:86)
	at io.quarkus.hibernate.orm.runtime.customized.QuarkusConnectionProvider.getConnection(QuarkusConnectionProvider.java:23)
	at org.hibernate.internal.NonContextualJdbcConnectionAccess.obtainConnection(NonContextualJdbcConnectionAccess.java:38)
	at org.hibernate.resource.jdbc.internal.LogicalConnectionManagedImpl.acquireConnectionIfNeeded(LogicalConnectionManagedImpl.java:113)
	at org.hibernate.resource.jdbc.internal.LogicalConnectionManagedImpl.getPhysicalConnection(LogicalConnectionManagedImpl.java:143)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl.connection(StatementPreparerImpl.java:51)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl$5.doPrepare(StatementPreparerImpl.java:150)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl$StatementPreparationTemplate.prepareStatement(StatementPreparerImpl.java:177)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl.prepareQueryStatement(StatementPreparerImpl.java:152)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.lambda$list$0(JdbcSelectExecutorStandardImpl.java:102)
	at org.hibernate.sql.results.jdbc.internal.DeferredResultSetAccess.executeQuery(DeferredResultSetAccess.java:226)
	at org.hibernate.sql.results.jdbc.internal.DeferredResultSetAccess.getResultSet(DeferredResultSetAccess.java:163)
	at org.hibernate.sql.results.jdbc.internal.JdbcValuesResultSetImpl.advanceNext(JdbcValuesResultSetImpl.java:254)
	at org.hibernate.sql.results.jdbc.internal.JdbcValuesResultSetImpl.processNext(JdbcValuesResultSetImpl.java:134)
	at org.hibernate.sql.results.jdbc.internal.AbstractJdbcValues.next(AbstractJdbcValues.java:19)
	at org.hibernate.sql.results.internal.RowProcessingStateStandardImpl.next(RowProcessingStateStandardImpl.java:66)
	at org.hibernate.sql.results.spi.ListResultsConsumer.consume(ListResultsConsumer.java:198)
	at org.hibernate.sql.results.spi.ListResultsConsumer.consume(ListResultsConsumer.java:33)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.doExecuteQuery(JdbcSelectExecutorStandardImpl.java:361)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.executeQuery(JdbcSelectExecutorStandardImpl.java:168)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.list(JdbcSelectExecutorStandardImpl.java:93)
	at org.hibernate.sql.exec.spi.JdbcSelectExecutor.list(JdbcSelectExecutor.java:31)
	at org.hibernate.query.sqm.internal.ConcreteSqmSelectQueryPlan.lambda$new$0(ConcreteSqmSelectQueryPlan.java:110)
	at org.hibernate.query.sqm.internal.ConcreteSqmSelectQueryPlan.withCacheableSqmInterpretation(ConcreteSqmSelectQueryPlan.java:303)
	at org.hibernate.query.sqm.internal.ConcreteSqmSelectQueryPlan.performList(ConcreteSqmSelectQueryPlan.java:244)
	at org.hibernate.query.sqm.internal.QuerySqmImpl.doList(QuerySqmImpl.java:518)
	at org.hibernate.query.spi.AbstractSelectionQuery.list(AbstractSelectionQuery.java:367)
	at org.hibernate.query.Query.getResultList(Query.java:119)
	at org.keycloak.models.jpa.MigrationModelAdapter.init(MigrationModelAdapter.java:59)
	at org.keycloak.models.jpa.MigrationModelAdapter.<init>(MigrationModelAdapter.java:42)
	at org.keycloak.models.jpa.JpaRealmProvider.getMigrationModel(JpaRealmProvider.java:99)
	at org.keycloak.storage.datastore.LegacyMigrationManager.migrate(LegacyMigrationManager.java:128)
	at org.keycloak.migration.MigrationModelManager.migrate(MigrationModelManager.java:33)
	at org.keycloak.quarkus.runtime.storage.legacy.database.LegacyJpaConnectionProviderFactory.migrateModel(LegacyJpaConnectionProviderFactory.java:216)
	at org.keycloak.quarkus.runtime.storage.legacy.database.LegacyJpaConnectionProviderFactory.initSchema(LegacyJpaConnectionProviderFactory.java:210)
	at org.keycloak.models.utils.KeycloakModelUtils.lambda$runJobInTransaction$1(KeycloakModelUtils.java:260)
	at org.keycloak.models.utils.KeycloakModelUtils.runJobInTransactionWithResult(KeycloakModelUtils.java:382)
	at org.keycloak.models.utils.KeycloakModelUtils.runJobInTransaction(KeycloakModelUtils.java:259)
	at org.keycloak.quarkus.runtime.storage.legacy.database.LegacyJpaConnectionProviderFactory.postInit(LegacyJpaConnectionProviderFactory.java:135)
	at org.keycloak.quarkus.runtime.integration.QuarkusKeycloakSessionFactory.init(QuarkusKeycloakSessionFactory.java:105)
	at org.keycloak.quarkus.runtime.integration.jaxrs.QuarkusKeycloakApplication.createSessionFactory(QuarkusKeycloakApplication.java:56)
	at org.keycloak.services.resources.KeycloakApplication.startup(KeycloakApplication.java:130)
	at org.keycloak.quarkus.runtime.integration.jaxrs.QuarkusKeycloakApplication.onStartupEvent(QuarkusKeycloakApplication.java:46)
	at org.keycloak.quarkus.runtime.integration.jaxrs.QuarkusKeycloakApplication_Observer_onStartupEvent_67d48587b481b764f44181a34540ebd3d495c2c7.notify(Unknown Source)
	at io.quarkus.arc.impl.EventImpl$Notifier.notifyObservers(EventImpl.java:346)
	at io.quarkus.arc.impl.EventImpl$Notifier.notify(EventImpl.java:328)
	at io.quarkus.arc.impl.EventImpl.fire(EventImpl.java:82)
	at io.quarkus.arc.runtime.ArcRecorder.fireLifecycleEvent(ArcRecorder.java:155)
	at io.quarkus.arc.runtime.ArcRecorder.handleLifecycleEvents(ArcRecorder.java:106)
	at io.quarkus.deployment.steps.LifecycleEventsBuildStep$startupEvent1144526294.deploy_0(Unknown Source)
	at io.quarkus.deployment.steps.LifecycleEventsBuildStep$startupEvent1144526294.deploy(Unknown Source)
	at io.quarkus.runner.ApplicationImpl.doStart(Unknown Source)
	at io.quarkus.runtime.Application.start(Application.java:101)
	at io.quarkus.runtime.ApplicationLifecycleManager.run(ApplicationLifecycleManager.java:111)
	at io.quarkus.runtime.Quarkus.run(Quarkus.java:71)
	at org.keycloak.quarkus.runtime.KeycloakMain.start(KeycloakMain.java:117)
	at org.keycloak.quarkus.runtime.cli.command.AbstractStartCommand.run(AbstractStartCommand.java:33)
	at picocli.CommandLine.executeUserObject(CommandLine.java:2026)
	at picocli.CommandLine.access$1500(CommandLine.java:148)
	at picocli.CommandLine$RunLast.executeUserObjectOfLastSubcommandWithSameParent(CommandLine.java:2461)
	at picocli.CommandLine$RunLast.handle(CommandLine.java:2453)
	at picocli.CommandLine$RunLast.handle(CommandLine.java:2415)
	at picocli.CommandLine$AbstractParseResultHandler.execute(CommandLine.java:2273)
	at picocli.CommandLine$RunLast.execute(CommandLine.java:2417)
	at picocli.CommandLine.execute(CommandLine.java:2170)
	at org.keycloak.quarkus.runtime.cli.Picocli.parseAndRun(Picocli.java:119)
	at org.keycloak.quarkus.runtime.KeycloakMain.main(KeycloakMain.java:107)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:568)
	at io.quarkus.bootstrap.runner.QuarkusEntryPoint.doRun(QuarkusEntryPoint.java:61)
	at io.quarkus.bootstrap.runner.QuarkusEntryPoint.main(QuarkusEntryPoint.java:32)

2024-01-15 13:11:45,598 WARN  [com.arjuna.ats.jta] (main) ARJUNA016138: Failed to enlist XA resource io.agroal.narayana.BaseXAResource@70d256e: jakarta.transaction.SystemException: TransactionImple.enlistResource - XAResource.start ARJUNA016054: could not register transaction: < formatId=131077, gtrid_length=35, bqual_length=36, tx_uid=0:ffffac160003:a743:65a52f11:0, node_name=quarkus, branch_uid=0:ffffac160003:a743:65a52f11:3f, subordinatenodename=null, eis_name=0 >
	at com.arjuna.ats.internal.jta.transaction.arjunacore.TransactionImple.enlistResource(TransactionImple.java:714)
	at com.arjuna.ats.internal.jta.transaction.arjunacore.TransactionImple.enlistResource(TransactionImple.java:422)
	at io.agroal.narayana.NarayanaTransactionIntegration.associate(NarayanaTransactionIntegration.java:93)
	at io.agroal.pool.ConnectionPool.getConnection(ConnectionPool.java:252)
	at io.agroal.pool.DataSource.getConnection(DataSource.java:86)
	at io.quarkus.hibernate.orm.runtime.customized.QuarkusConnectionProvider.getConnection(QuarkusConnectionProvider.java:23)
	at org.hibernate.internal.NonContextualJdbcConnectionAccess.obtainConnection(NonContextualJdbcConnectionAccess.java:38)
	at org.hibernate.resource.jdbc.internal.LogicalConnectionManagedImpl.acquireConnectionIfNeeded(LogicalConnectionManagedImpl.java:113)
	at org.hibernate.resource.jdbc.internal.LogicalConnectionManagedImpl.getPhysicalConnection(LogicalConnectionManagedImpl.java:143)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl.connection(StatementPreparerImpl.java:51)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl$5.doPrepare(StatementPreparerImpl.java:150)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl$StatementPreparationTemplate.prepareStatement(StatementPreparerImpl.java:177)
	at org.hibernate.engine.jdbc.internal.StatementPreparerImpl.prepareQueryStatement(StatementPreparerImpl.java:152)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.lambda$list$0(JdbcSelectExecutorStandardImpl.java:102)
	at org.hibernate.sql.results.jdbc.internal.DeferredResultSetAccess.executeQuery(DeferredResultSetAccess.java:226)
	at org.hibernate.sql.results.jdbc.internal.DeferredResultSetAccess.getResultSet(DeferredResultSetAccess.java:163)
	at org.hibernate.sql.results.jdbc.internal.JdbcValuesResultSetImpl.advanceNext(JdbcValuesResultSetImpl.java:254)
	at org.hibernate.sql.results.jdbc.internal.JdbcValuesResultSetImpl.processNext(JdbcValuesResultSetImpl.java:134)
	at org.hibernate.sql.results.jdbc.internal.AbstractJdbcValues.next(AbstractJdbcValues.java:19)
	at org.hibernate.sql.results.internal.RowProcessingStateStandardImpl.next(RowProcessingStateStandardImpl.java:66)
	at org.hibernate.sql.results.spi.ListResultsConsumer.consume(ListResultsConsumer.java:198)
	at org.hibernate.sql.results.spi.ListResultsConsumer.consume(ListResultsConsumer.java:33)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.doExecuteQuery(JdbcSelectExecutorStandardImpl.java:361)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.executeQuery(JdbcSelectExecutorStandardImpl.java:168)
	at org.hibernate.sql.exec.internal.JdbcSelectExecutorStandardImpl.list(JdbcSelectExecutorStandardImpl.java:93)
	at org.hibernate.sql.exec.spi.JdbcSelectExecutor.list(JdbcSelectExecutor.java:31)
	at org.hibernate.query.sqm.internal.ConcreteSqmSelectQueryPlan.lambda$new$0(ConcreteSqmSelectQueryPlan.java:110)
	at org.hibernate.query.sqm.internal.ConcreteSqmSelectQueryPlan.withCacheableSqmInterpretation(ConcreteSqmSelectQueryPlan.java:303)
	at org.hibernate.query.sqm.internal.ConcreteSqmSelectQueryPlan.performList(ConcreteSqmSelectQueryPlan.java:244)
	at org.hibernate.query.sqm.internal.QuerySqmImpl.doList(QuerySqmImpl.java:518)
	at org.hibernate.query.spi.AbstractSelectionQuery.list(AbstractSelectionQuery.java:367)
	at org.hibernate.query.Query.getResultList(Query.java:119)
	at org.keycloak.models.jpa.MigrationModelAdapter.init(MigrationModelAdapter.java:59)
	at org.keycloak.models.jpa.MigrationModelAdapter.<init>(MigrationModelAdapter.java:42)
	at org.keycloak.models.jpa.JpaRealmProvider.getMigrationModel(JpaRealmProvider.java:99)
	at org.keycloak.storage.datastore.LegacyMigrationManager.migrate(LegacyMigrationManager.java:128)
	at org.keycloak.migration.MigrationModelManager.migrate(MigrationModelManager.java:33)
	at org.keycloak.quarkus.runtime.storage.legacy.database.LegacyJpaConnectionProviderFactory.migrateModel(LegacyJpaConnectionProviderFactory.java:216)
	at org.keycloak.quarkus.runtime.storage.legacy.database.LegacyJpaConnectionProviderFactory.initSchema(LegacyJpaConnectionProviderFactory.java:210)
	at org.keycloak.models.utils.KeycloakModelUtils.lambda$runJobInTransaction$1(KeycloakModelUtils.java:260)
	at org.keycloak.models.utils.KeycloakModelUtils.runJobInTransactionWithResult(KeycloakModelUtils.java:382)
	at org.keycloak.models.utils.KeycloakModelUtils.runJobInTransaction(KeycloakModelUtils.java:259)
	at org.keycloak.quarkus.runtime.storage.legacy.database.LegacyJpaConnectionProviderFactory.postInit(LegacyJpaConnectionProviderFactory.java:135)
	at org.keycloak.quarkus.runtime.integration.QuarkusKeycloakSessionFactory.init(QuarkusKeycloakSessionFactory.java:105)
	at org.keycloak.quarkus.runtime.integration.jaxrs.QuarkusKeycloakApplication.createSessionFactory(QuarkusKeycloakApplication.java:56)
	at org.keycloak.services.resources.KeycloakApplication.startup(KeycloakApplication.java:130)
	at org.keycloak.quarkus.runtime.integration.jaxrs.QuarkusKeycloakApplication.onStartupEvent(QuarkusKeycloakApplication.java:46)
	at org.keycloak.quarkus.runtime.integration.jaxrs.QuarkusKeycloakApplication_Observer_onStartupEvent_67d48587b481b764f44181a34540ebd3d495c2c7.notify(Unknown Source)
	at io.quarkus.arc.impl.EventImpl$Notifier.notifyObservers(EventImpl.java:346)
	at io.quarkus.arc.impl.EventImpl$Notifier.notify(EventImpl.java:328)
	at io.quarkus.arc.impl.EventImpl.fire(EventImpl.java:82)
	at io.quarkus.arc.runtime.ArcRecorder.fireLifecycleEvent(ArcRecorder.java:155)
	at io.quarkus.arc.runtime.ArcRecorder.handleLifecycleEvents(ArcRecorder.java:106)
	at io.quarkus.deployment.steps.LifecycleEventsBuildStep$startupEvent1144526294.deploy_0(Unknown Source)
	at io.quarkus.deployment.steps.LifecycleEventsBuildStep$startupEvent1144526294.deploy(Unknown Source)
	at io.quarkus.runner.ApplicationImpl.doStart(Unknown Source)
	at io.quarkus.runtime.Application.start(Application.java:101)
	at io.quarkus.runtime.ApplicationLifecycleManager.run(ApplicationLifecycleManager.java:111)
	at io.quarkus.runtime.Quarkus.run(Quarkus.java:71)
	at org.keycloak.quarkus.runtime.KeycloakMain.start(KeycloakMain.java:117)
	at org.keycloak.quarkus.runtime.cli.command.AbstractStartCommand.run(AbstractStartCommand.java:33)
	at picocli.CommandLine.executeUserObject(CommandLine.java:2026)
	at picocli.CommandLine.access$1500(CommandLine.java:148)
	at picocli.CommandLine$RunLast.executeUserObjectOfLastSubcommandWithSameParent(CommandLine.java:2461)
	at picocli.CommandLine$RunLast.handle(CommandLine.java:2453)
	at picocli.CommandLine$RunLast.handle(CommandLine.java:2415)
	at picocli.CommandLine$AbstractParseResultHandler.execute(CommandLine.java:2273)
	at picocli.CommandLine$RunLast.execute(CommandLine.java:2417)
	at picocli.CommandLine.execute(CommandLine.java:2170)
	at org.keycloak.quarkus.runtime.cli.Picocli.parseAndRun(Picocli.java:119)
	at org.keycloak.quarkus.runtime.KeycloakMain.main(KeycloakMain.java:107)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:568)
	at io.quarkus.bootstrap.runner.QuarkusEntryPoint.doRun(QuarkusEntryPoint.java:61)
	at io.quarkus.bootstrap.runner.QuarkusEntryPoint.main(QuarkusEntryPoint.java:32)
```