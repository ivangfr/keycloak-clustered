# keycloak-clustered

**Keycloak-Clustered** extends [`Keycloak Official Docker Image`](https://hub.docker.com/r/jboss/keycloak). It allows running easily a cluster of [Keycloak](https://www.keycloak.org) instances.

The current `Keycloak Official Docker Image` supports `PING` discovery protocol out of the box. However, `PING` just works when the Keycloak docker containers are running in the same host or data center. If you have Keycloak containers running in different hosts or data centers you must use `JDBC_PING` or `TCPPING`.

In this `Keycloak-Clustered` Docker Image, we added scripts that enable us to create a Keycloak cluster using `JDBC_PING` or `TCPPING` discovery protocols.

More about `PING`, `JDBC_PING` and `TCPPING` discovery protocols at https://www.keycloak.org/2019/05/keycloak-cluster-setup.html.

> **IMPORTANT:** Currently, `TCPPING` is not working!

## Discovery Protocols

### JDBC_PING

In order to use `JDBC_PING`. we need to set three environment variables
```
#IP address of this host, please make sure this IP can be accessed by the other Keycloak instances
JGROUPS_DISCOVERY_EXTERNAL_IP=10.0.0.11

#protocol
JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING

#datasource jndi name
JGROUPS_DISCOVERY_PROPERTIES=datasource_jndi_name=java:jboss/datasources/KeycloakDS
```

### TCPPING

In order to use `TCPPING`, we need to set three environment variables
```
#IP address of this host, please make sure this IP can be accessed by the other Keycloak instances
JGROUPS_DISCOVERY_EXTERNAL_IP=10.0.0.11

#protocol
JGROUPS_DISCOVERY_PROTOCOL=TCPPING

#IP and Port of all host
JGROUPS_DISCOVERY_PROPERTIES=initial_hosts="10.0.0.11[7600],10.0.0.12[7600]"
```

## Supported tags and respective Dockerfile links

- `16.1.0`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/16.1.0/Dockerfile))

## Author

Ivan Franchin ([LinkedIn](https://www.linkedin.com/in/ivanfranchin)) ([Github](https://github.com/ivangfr))

## Environment Variables

Please, refer to the official `jboss/keycloak` documentation at https://hub.docker.com/r/jboss/keycloak

## How to build locally a development Docker image

Navigate into one oof the version folders and run the following command
```
docker build -t keycloak-clustered:development .
```

## How to check if Keycloak instances are sharing user sessions

1. Open two different browsers, for instance `Chrome` and `Safari` or `Chrome` and `Incognito Chrome`.

1. In one access `http://localhost:8080/auth/admin/` and, in another, `http://localhost:8081/auth/admin/`

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

## Running a Keycloak Cluster using PING in a local Docker network

### Prerequisites

[`Docker`](https://www.docker.com/)

### Using MySQL

- #### Startup

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
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=mysql \
  -e DB_ADDR=mysql \
  -e DB_DATABASE=keycloak \
  -e DB_USER=keycloak \
  -e DB_PASSWORD=password \
  -e JDBC_PARAMS=useSSL=false \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest
  ```

  Finally, open another terminal and run `keycloak-clustered-2` Docker container
  ```
  docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=mysql \
  -e DB_ADDR=mysql \
  -e DB_DATABASE=keycloak \
  -e DB_USER=keycloak \
  -e DB_PASSWORD=password \
  -e JDBC_PARAMS=useSSL=false \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest
  ```

- #### Testing

  In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

- #### Teardown

  To stop `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

  To stop `mysql` Docker container, press `Ctrl+\` in its terminal;

  To remove Docker network, run in a terminal
  ```
  docker network rm keycloak-net
  ```

## Running a Keycloak Cluster using JDBC_PING in a local Docker network

### Prerequisites

[`Docker`](https://www.docker.com/)

### Using Postgres

- #### Startup

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
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=postgres \
  -e DB_ADDR=postgres \
  -e DB_DATABASE=keycloak \
  -e DB_SCHEMA=myschema \
  -e DB_USER=keycloak \
  -e DB_PASSWORD=password \
  -e JDBC_PARAMS=useSSL=false \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  -e JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING \
  -e JGROUPS_DISCOVERY_PROPERTIES=datasource_jndi_name=java:jboss/datasources/KeycloakDS \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest
  ```

  Finally, open another terminal and run `keycloak-clustered-2` Docker container
  ```
  docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=postgres \
  -e DB_ADDR=postgres \
  -e DB_DATABASE=keycloak \
  -e DB_SCHEMA=myschema \
  -e DB_USER=keycloak \
  -e DB_PASSWORD=password \
  -e JDBC_PARAMS=useSSL=false \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  -e JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING \
  -e JGROUPS_DISCOVERY_PROPERTIES=datasource_jndi_name=java:jboss/datasources/KeycloakDS \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest
  ```

- #### Testing

  In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

- #### Check database

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

- #### Teardown

  To stop `postgres`, `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

  To remove Docker network, run in a terminal
  ```
  docker network rm keycloak-net
  ```

### Using Microsoft SQL Server

- #### Startup

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

  Create `keycloak` database
  ```
  docker exec -i mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P my_Password -Q 'CREATE DATABASE keycloak'
  ```

  Open another terminal and run `keycloak-clustered-1` Docker container
  ```
  docker run --rm --name keycloak-clustered-1 -p 8080:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=mssql \
  -e DB_ADDR=mssql \
  -e DB_DATABASE=keycloak \
  -e DB_SCHEMA=myschema \
  -e DB_USER=SA \
  -e DB_PASSWORD=my_Password \
  -e JDBC_PARAMS=useSSL=false \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-1 \
  -e JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING \
  -e JGROUPS_DISCOVERY_PROPERTIES=datasource_jndi_name=java:jboss/datasources/KeycloakDS \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest
  ```

  Finally, open another terminal and run `keycloak-clustered-2` Docker container
  ```
  docker run --rm --name keycloak-clustered-2 -p 8081:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=mssql \
  -e DB_ADDR=mssql \
  -e DB_DATABASE=keycloak \
  -e DB_SCHEMA=myschema \
  -e DB_USER=SA \
  -e DB_PASSWORD=my_Password \
  -e JDBC_PARAMS=useSSL=false \
  -e JGROUPS_DISCOVERY_EXTERNAL_IP=keycloak-clustered-2 \
  -e JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING \
  -e JGROUPS_DISCOVERY_PROPERTIES=datasource_jndi_name=java:jboss/datasources/KeycloakDS \
  --network keycloak-net \
  ivanfranchin/keycloak-clustered:latest
  ```

- #### Testing

  In order to test it, have a look at [How to check if keycloak-clustered instances are sharing user sessions](#how-to-check-if-keycloak-instances-are-sharing-user-sessions)

- #### Check database

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

- #### Teardown

  To stop `keycloak-clustered-1` and `keycloak-clustered-2` Docker containers, press `Ctrl+C` in their terminals;

  To remove Docker network, run in a terminal
  ```
  docker network rm keycloak-net
  ```

## Running a Keycloak Cluster using JDBC_PING or TCPPING in Virtual Machines

### Prerequisites

[`VirtualBox`](https://www.virtualbox.org/) and [`Vagrant`](https://www.vagrantup.com/docs/installation)

### Startup

Open a terminal and make sure you are in `keycloak-clustered` root folder

You can edit `Vagrantfile` and set the database and/or the discovery protocol to be used

Start the virtual machines by running the command below
```
vagrant up
```

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
  vagrant@vagrant:~$ docker exec -it mysql mysql -ukeycloak -ppassword --database=keycloak
  mysql> show tables;
  mysql> SELECT * FROM JGROUPSPING;
  ```
  > **Note:** To exit type `exit`

- MariaDB
  ```
  vagrant@vagrant:~$ docker exec -it mariadb mysql -ukeycloak -ppassword --database=keycloak
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

### Using another discovery protocol

Edit `Vagrantfile` by setting to `DISCOVERY_PROTOCOL` variable the discovery protocol to be used

Reload Keycloak virtual machines by running
```
vagrant reload keycloak1 keycloak2 --provision
```

### Using another database

Edit `Vagrantfile` by setting to `DB_VENDOR` variable the database to be used

Reload Keycloak virtual machines by running
```
vagrant reload keycloak1 keycloak2 --provision
```

### Changing discovery protocol script

In the host machine, go to the version folder where the script is, open and edit it

Edit `Vagrantfile` by setting to
- `BUILD_IMAGE_VERSION` variable the version number
- `BUILD_DOCKER_IMAGE` variable the value `true`

Reload Keycloak virtual machines by running
```
vagrant reload keycloak1 keycloak2 --provision
```

### Using jboss-cli to test scripts

Get inside one of the Keycloak virtual machines
```
vagrant ssh keycloak1
```

Once inside, get inside the `keycloak-clustered` Docker container
```
docker exec -it keycloak-clustered bash
```

In order to test discovery scripts, there are two ways:

1. Running a script directly, for instance
   ```
   cd opt/jboss/keycloak/bin
   ./jboss-cli.sh --file=/opt/jboss/tools/cli/jgroups/discovery/TCPPING.cli
   ```

1. Running command-by-command using the terminal

   Access `jboss-cli` by running the command below
   ```
   cd opt/jboss/keycloak/bin
   ./jboss-cli.sh --connect
   ```

   Once in `jboss-cli` terminal, we can run all available commands, for instance
   ```
   /subsystem=datasources/data-source=KeycloakDS:read-resource(recursive=true)
   /subsystem=datasources/data-source=KeycloakDS:read-attribute(name=driver-name)
   ```

   For more information check https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.0/html-single/management_cli_guide/index#use_if_else_control_flow

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
