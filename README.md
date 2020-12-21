# keycloak-clustered

**Keycloak-Clustered** extends [`Keycloak Official Docker Image`](https://hub.docker.com/r/jboss/keycloak). It allows running easily a cluster of [Keycloak](https://www.keycloak.org) instances.

The current `Keycloak Official Docker Image` supports `PING` discovery protocol out of the box. However, `PING` just works when the Keycloak docker containers are running in the same host or data center. If you have Keycloak containers running in different hosts or data centers you must use `TCPPING` or `JDBC_PING`.

In this `Keycloak-Clustered` Docker Image, we added scripts that enable us to create a Keycloak cluster using `TCPPING` or `JDBC_PING` discovery protocols.

More about `PING`, `TCPPING` and `JDBC_PING` discovery protocols at https://www.keycloak.org/2019/04/keycloak-cluster-setup.html.

## Discovery Protocols

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

## Supported tags and respective Dockerfile links

- `12.0.1`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/12.0.1/Dockerfile))
- `11.0.3` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/11.0.3/Dockerfile))
- `11.0.2` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/11.0.2/Dockerfile))
- `11.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/11.0.1/Dockerfile))
- `11.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/11.0.0/Dockerfile))
- `10.0.2` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/10.0.2/Dockerfile))
- `10.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/10.0.1/Dockerfile))
- `10.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/10.0.0/Dockerfile))

## Author

Ivan Franchin ([LinkedIn](https://www.linkedin.com/in/ivanfranchin)) ([Github](https://github.com/ivangfr))

## Environment Variables

Please, refer to the official `jboss/keycloak` documentation at https://hub.docker.com/r/jboss/keycloak

## Running a Keycloak Cluster using PING in a local Docker network

### Prerequisites

- [`Docker`](https://www.docker.com/)

### Startup

- Create network
  ```
  docker network create keycloak-net
  ```

- Start [MySQL](https://hub.docker.com/_/mysql) container
  ```
  docker run -d --rm \
  --name mysql \
  --network keycloak-net \
  -p 3306:3306 \
  -e MYSQL_DATABASE=keycloak \
  -e MYSQL_USER=keycloak \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_ROOT_PASSWORD=root_password \
  mysql:5.7.32
  ```

- Run `keycloak-clustered-1`
  ```
  docker run -d --rm \
  --name keycloak-clustered-1 \
  --network keycloak-net \
  -p 8080:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=mysql \
  -e DB_ADDR=mysql \
  -e DB_USER=keycloak \
  -e DB_PASSWORD=password \
  -e JDBC_PARAMS=useSSL=false \
  ivanfranchin/keycloak-clustered:latest
  ```

- Run `keycloak-clustered-2`
  ```
  docker run -d --rm \
  --name keycloak-clustered-2 \
  --network keycloak-net \
  -p 8081:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=mysql \
  -e DB_ADDR=mysql \
  -e DB_USER=keycloak \
  -e DB_PASSWORD=password \
  -e JDBC_PARAMS=useSSL=false \
  ivanfranchin/keycloak-clustered:latest
  ```

### Check if keycloak-clustered instances are sharing user sessions

  - Open two different browsers, for instance Chrome and Safari or Chrome and Incognito Chrome. In one access `http://localhost:8080/auth/admin/` and, in another, `http://localhost:8081/auth/admin/` 
   
  - Login with the following credentials
    ```
    username: admin
    password: admin
    ```
   
  - Once logged in, on the menu on the left, click on `Users` and then on `View All` button. The `admin` will appear. Then, click on `admin`'s `Edit` button and, finally, click on `Sessions` tab. You should see that `admin` has two sessions.

### Teardown

 - Remove containers
   ```
   docker stop keycloak-clustered-1 keycloak-clustered-2 mysql
   ```

 - Remove network
   ```
   docker network rm keycloak-net
   ```

## Running a Keycloak Cluster using JDBC_PING OR TCPPING in Virtual Machines

### Prerequisites

- [`VirtualBox`](https://www.virtualbox.org/)
- [`Vagrant`](https://www.vagrantup.com/docs/installation)

### Startup

- Open a terminal and make sure you are in `keycloak-clustered` root folder 

- You can edit `Vagrantfile` and set the database and/or the discovery protocol to be used

- Start the virtual machines by running the command below
  ```
  vagrant up
  ```
   
- Wait a bit until the virtual machines get started. It will take some time.

- Once all the execution of the command `vagrant up` finishes, we can check the state of all active Vagrant environments
  ```
  vagrant status
  ```

- Check `keycloak-clustered` docker logs in `keycloak1` virtual machine
  ```
  vagrant ssh keycloak1
  vagrant@vagrant:~$ docker logs keycloak-clustered -f
  ```
  > **Note:** To get out of the logging view press `Ctrl+C` and to exit the virtual machine type `exit`

- Check `keycloak-clustered` docker logs in `keycloak2` virtual machine
  ```
  vagrant ssh keycloak2
  vagrant@vagrant:~$ docker logs keycloak-clustered -f
  ```
  > **Note:** To get out of the logging view press `Ctrl+C` and to exit the virtual machine type `exit`

- Check the databases
  ```
  vagrant ssh databases
  ```
  > **Note:** To exit the virtual machine type `exit`

  - MySQL
    ```
    vagrant@vagrant:~$ docker exec -it mysql mysql -ukeycloak -ppassword --database=keycloak
    mysql> show tables;
    ```
    > **Note 1:** If you are using `JDBC_PING`, you can select `JGROUPSPING` table and see the machine records, `SELECT * FROM JGROUPSPING;`
    >
    > **Note 2:** To exit type `exit`

  - MariaDB
    ```
    vagrant@vagrant:~$ docker exec -it mariadb mysql -ukeycloak -ppassword --database=keycloak
    MariaDB [keycloak]> show tables;
    ```
    > **Note 1:** If you are using `JDBC_PING`, you can select `JGROUPSPING` table and see the machine records, `SELECT * FROM JGROUPSPING;`
    >
    > **Note 2:** To exit type `exit`
     
  - Postgres
    ```
    vagrant@vagrant:~$ docker exec -it postgres psql -U keycloak
    keycloak=# \d
    ```
    > **Note 1:** If you are using `JDBC_PING`, you can select `JGROUPSPING` table and see the machine records, `SELECT * FROM JGROUPSPING;`
    >
    > **Note 2:** To exit type `\q`

### Check if keycloak-clustered instances are sharing user sessions 

  - Open two different browsers, for instance Chrome and Safari or Chrome and Incognito Chrome. In one access `http://localhost:8080/auth/admin/` and, in another, `http://localhost:8081/auth/admin/` 
   
  - Login with the following credentials
    ```
    username: admin
    password: admin
    ```
   
   - Once logged in, on the menu on the left, click on `Users` and then on `View All` button. The `admin` will appear. Then, click on `admin`'s `Edit` button and, finally, click on `Sessions` tab. You should see that `admin` has two sessions.

### Using another discovery protocol

- Edit the `Vagrantfile` by setting to `DISCOVERY_PROTOCOL` variable the discovery protocol to be used

- Reload Keycloak virtual machines by running
  ```
  vagrant reload keycloak1 keycloak2 --provision
  ```

### Using another database

- Edit the `Vagrantfile` by setting to `DB_VENDOR` variable the database to be used

- Reload Keycloak virtual machines by running
  ```
  vagrant reload keycloak1 keycloak2 --provision
  ```
   
### Changing discovery protocol script

- In the host machine, go to the version folder where the script is, open and edit it

- Edit the `Vagrantfile` by setting to
  - `BUILD_IMAGE_VERSION` variable the version number 
  - `BUILD_DOCKER_IMAGE` variable the value `true`

- Reload Keycloak virtual machines by running
  ```
  vagrant reload keycloak1 keycloak2 --provision
  ```

### Using jboss-cli to test scripts

- Get inside one of the Keycloak virtual machines
  ```
  vagrant ssh keycloak1
  ```

- Once inside, get inside the `keycloak-clustered` Docker container
  ```
  docker exec -it keycloak-clustered bash
  ```

- In order to test discovery scripts, there are two ways:

  1. Running a script directly, for instance
     ```
     cd opt/jboss/keycloak/bin
     ./jboss-cli.sh --file=/opt/jboss/tools/cli/jgroups/discovery/TCPPING.cli
     ```
  
  1. Running command-by-command using the terminal

     - Access `jboss-cli` by running the command below
       ```
       cd opt/jboss/keycloak/bin
       ./jboss-cli.sh --connect
       ```

     - Once in `jboss-cli` terminal, we can run all available commands, for instance
       ```
       /subsystem=datasources/data-source=KeycloakDS:read-resource(recursive=true)
       /subsystem=datasources/data-source=KeycloakDS:read-attribute(name=driver-name)
       ```
     
       For more information check https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.0/html-single/management_cli_guide/index#use_if_else_control_flow

### Teardown

- **Suspend the machines**

  Suspending the virtual machines will stop them and save their current running state. For it run
  ```
  vagrant suspend
  ```

  To bring the virtual machines back up run
  ```
  vagrant up
  ```

- **Halt the machines**

  Halting the virtual machines will gracefully shut down the guest operating system and power down the guest machine
  ```
  vagrant halt
  ```
  
  It preserves the contents of disk and allows to start it again by running
  ```
  vagrant up
  ```

- **Destroy the machines**

  Destroying the virtual machine will remove all traces of the guest machine from your system. It'll stop the guest machine, power it down, and reclaim its disk space and RAM.
  ```
  vagrant destroy -f
  ```
  
  For a complete clean up, you can remove Vagrant box used in this section
  ```
  vagrant box remove hashicorp/bionic64
  ```
