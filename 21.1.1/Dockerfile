FROM quay.io/keycloak/keycloak:21.1.1

ENV KC_DB=database_vendor
ENV KC_DB_USERNAME=username
ENV KC_DB_PASSWORD=password
ENV KC_DB_SCHEMA=database_name
ENV KC_DB_URL_HOST=database_host
ENV KC_DB_URL=jdbc:database_vendor://database_host/database_name

# Default port for keycloak. Better choise for any load-balanced/clustered enviroment
EXPOSE 80

# Default port for jdbc-ping. Should be accesible in each node (EC2,ECS,...)
# This should NATed in a container, opened in the firewall,...
# and manage the access
EXPOSE 57800

ENV JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING

# This should be the IP of the EC2, the IP of the Dockerhost,
# or the name of the Docker container in a local docker-network
# or the floating IP in a Kubernetes env
# It's the binded bind_addr for the service
ENV JGROUPS_DISCOVERY_EXTERNAL_IP=ip_for_jdbc-ping_listen_interface

COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml

ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml
