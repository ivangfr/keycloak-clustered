# `keycloak-clustered`

**Keycloak-Clustered** extends [`Keycloak Official Docker Image`](https://hub.docker.com/r/jboss/keycloak). It allows to run easily a cluster of [Keycloak](https://www.keycloak.org) instances.

The current `Keycloak Official Docker Image` supports `PING` discovery protocol out of the box. However, `PING` just works when the Keycloak docker containers are running in the same host or data center. If you have Keycloak containers running in different hosts or data centers you must use `TCPPING` or `JDBC_PING`.

In the `Keycloak-Clustered` Docker Image, two script were added: `TCPPING.cli` and `JDBC_PING.cli`. They enable us to create a Keycloak cluster using `TCPPING` or `JDBC_PING` discovery protocols.

More about `PING`, `TCPPING` and `JDBC_PING` discovery protocols at https://www.keycloak.org/2019/05/keycloak-cluster-setup.html.

## Supported tags and respective Dockerfile links

- `8.0.1`, `latest` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/8.0.1/Dockerfile))
- `8.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/8.0.0/Dockerfile))
- `7.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/7.0.1/Dockerfile))
- `7.0.0` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/7.0.0/Dockerfile))
- `6.0.1` ([Dockerfile](https://github.com/ivangfr/keycloak-clustered/blob/master/6.0.1/Dockerfile))

## Author

Ivan Franchin ([LinkedIn](https://www.linkedin.com/in/ivanfranchin)) ([Github](https://github.com/ivangfr))

## Environment Variables

Please, refer to the official `jboss/keycloak` documentation at https://hub.docker.com/r/jboss/keycloak

## Build the docker image locally

Go the version folder and run the docker build command
```
docker build -t ivanfranchin/keycloak-clustered:latest .
```

## Running a Keycloak Cluster using PING

1. Create network
   ```
   docker network create keycloak-net
   ```

1. Start [MySQL](https://hub.docker.com/_/mysql) container
   ```
   docker run -d --rm \
   --name mysql \
   --network keycloak-net \
   -p 3306:3306 \
   -e MYSQL_DATABASE=keycloak \
   -e MYSQL_USER=keycloak \
   -e MYSQL_PASSWORD=password \
   -e MYSQL_ROOT_PASSWORD=root_password \
   mysql:5.7.28
   ```

1. Run `keycloak-clustered-1`
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

1. Run `keycloak-clustered-2`
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
   
1. Check if `keycloak-clustered` instances are sharing user sessions

   - Open two different browsers, for instance Chrome and Safari or Chrome and Incognito Chrome. In one access
   `http://localhost:8080` and in another `http://localhost:8081` 
   
   - Login with the following credentials
     ```
     username: admin
     password: admin
     ```
   
   - Once logged in, on the menu on the left, click on `Users` and then on `View All` button. The `admin` will appear.
   Next, click on `admin`'s `Edit` button and, finally, click on `Sessions` tab. You should see that `admin` has two sessions.

1. Shutdown

   - Remove containers
   ```
   docker stop keycloak-clustered-1 keycloak-clustered-2 mysql
   ```
   
   - Remove network
   ```
   docker network rm keycloak-net
   ```

## Running a Keycloak Cluster using JDBC_PING

1. Start a cluster of Docker Engine in Swarm Mode. Here, two docker machines will be created. One will act as the
   **Manager (Leader)** and the another will be the **Worker**. The manager machine will be called `manager1` and the
   worker machine, `worker1`.
   ```
   setup-docker-swarm.sh
   ```
 
1. Set the `manager1` Docker Daemon
   ```
   eval $(docker-machine env manager1)
   ```
   > **Note:** to get back to the Docker Daemon of the Host machine run
   > ```
   > eval $(docker-machine env -u)
   > ```

1. Create [MySQL](https://hub.docker.com/_/mysql) service
   ```
   docker service create \
   --name mysql \
   --replicas 1 \
   --network my-swarm-net \
   -p 3306:3306 \
   -e MYSQL_DATABASE=keycloak \
   -e MYSQL_USER=keycloak \
   -e MYSQL_PASSWORD=password \
   -e MYSQL_ROOT_PASSWORD=root_password \
   mysql:5.7.28
   ```

1. Create two instances of `keycloak-clustered` service
   ```
   docker service create \
   --name keycloak-clustered \
   --replicas 2 \
   --network my-swarm-net \
   -p 8080:8080 \
   -e KEYCLOAK_USER=admin \
   -e KEYCLOAK_PASSWORD=admin \
   -e DB_VENDOR=mysql \
   -e DB_ADDR=mysql \
   -e DB_USER=keycloak \
   -e DB_PASSWORD=password \
   -e JDBC_PARAMS=useSSL=false \
   -e JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING \
   -e JGROUPS_DISCOVERY_PROPERTIES=datasource_jndi_name=java:jboss/datasources/KeycloakDS \
   ivanfranchin/keycloak-clustered:latest
   ```

1. Get more info about `keycloak-clustered` instances
   ```
   docker service ps keycloak-clustered
   ```
   You should see something similar to what it's shown below, with one instance running in `manager1` and another in `worker1`
   ```
   ID                  NAME                   IMAGE                                    NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
   kuags8qas1i0        keycloak-clustered.1   ivanfranchin/keycloak-clustered:latest   worker1             Running             Running 10 seconds ago
   jd3t4lkk8gfa        keycloak-clustered.2   ivanfranchin/keycloak-clustered:latest   manager1            Running             Running 11 seconds ago
   ```

1. Check if `keycloak-clustered` instances are sharing user sessions

   - Get Keycloak URL
     ```
     echo "http://$(docker-machine ip manager1):8080"
     ```
   
   - Copy the URL above and paste it in two different browsers, for instance Chrome and Safari or Chrome and Incognito Chrome
   
   - Login with the following credentials
     ```
     username: admin
     password: admin
     ```
   
   - Once logged in, on the menu on the left, click on `Users` and then on `View All` button. The `admin` will appear.
   Next, click on `admin`'s `Edit` button and, finally, click on `Sessions` tab. You should see that `admin` has two sessions.
   
1. Check records in `JGROUPSPING` table

   - Find on which machine `MySQL` is running
     ```
     docker service ps mysql
     ```
     You should see something like
     ```
     ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
     u1iygxg7gv6l        mysql.1             mysql:5.7.28        manager1            Running             Running 5 minutes ago
     ```
     
     > **Note:** In my case, it is running on `manager1`. However, if it is running on `worker1`, I must change to `worker1` Docker Daemon by running
     > ```
     > eval $(docker-machine env worker1)
     > ```
   
   - Get running `MySQL` docker container
     ```
     MYSQL_CONTAINER=$(docker ps --format '{{.Names}}' | grep mysql)
     ```
     
   - Run `docker exec` on the running `MySQL` docker container
     ```
     docker exec -it $MYSQL_CONTAINER mysql -ukeycloak -ppassword
     ```
   
   - Inside `MySQL` run the following `select`
     ```
     select * from keycloak.JGROUPSPING;
     ```
     
1. Shutdown

   - Remove services
   ```
   docker service rm keycloak-clustered mysql
   ```
   
   - Remove docker machines
   ```
   docker-machine rm manager1 worker1
   ```