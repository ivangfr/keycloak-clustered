FROM quay.io/keycloak/keycloak:21.1.1

# Enable a route for the balancer/reverse proxy/... 
# (AWS LoadBalancer/nginx/...) to detect failure on any of the nodes
# The path is usually /health, but better consult the documentation
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Recomended configuration for clustered environments
ENV KC_PROXY=edge
ENV KC_HOSTNAME_STRICT=false

ENV KC_HTTP_PORT=80
ENV KC_HTTP_ENABLED=true

ENV KEYCLOAK_ADMIN=your_admin_login
ENV KEYCLOAK_ADMIN_PASSWORD=your_admin_password

ENV KC_DB=database_vendor
ENV KC_DB_USERNAME=database_username
ENV KC_DB_PASSWORD=database_password
ENV KC_DB_SCHEMA=database_name
ENV KC_DB_URL_HOST=database_host
ENV KC_DB_URL=jdbc:database_vendor://database_host/database_name

# Default port for keycloak.
# Using HTTP should be a better option for any cluster
# environment (AWS LoadBalancer, Kubernetes,...)
# Example: docker run -p 80:80 this_image
EXPOSE 80

# Default ports for jdbc-ping. Should be accesible in each node (EC2,ECS,...)
# This should NATed in a container, opened in the firewall,...
# and manage its security as another service
# Example: docker run -p 7800:7800 -p 57800:57800 this_image
EXPOSE 7800
EXPOSE 57800

# Set your trace level once the service has started
# Note that this example uses a clustered environment, so
# infinispan service management is required
ENV KC_LOG_LEVEL: INFO,org.infinispan:TRACE,org.jgroups:DEBUG

ENV JGROUPS_DISCOVERY_PROTOCOL=JDBC_PING

# This should be the IP of the EC2, the IP of the Dockerhost,
# or the name of the Docker container in a local docker-network
# or the floating IP in a Kubernetes env
# It's the binded bind_addr for the service
ENV JGROUPS_DISCOVERY_EXTERNAL_IP=ip_for_jdbc-ping_listen_interface

# Note that this file configures the infinispan (ispn) service
# based on the environment variables defined above.
COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml

ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml

# As the result, you will get a new table, database_name.JGROUPSPING 
# with as many records as active nodes maintain the cluster.
# The IP corresponds to the "master" node (the first to boot in the cluster)
# and will change if any of the nodes becomes unavailable
#
#+--------------------------------------+--------------+----------------+---------------------+------------------------------------------------------------------------------------------------------+
#| own_addr                             | cluster_name | bind_addr      | updated             | ping_data |
#+--------------------------------------+--------------+----------------+---------------------+------------------------------------------------------------------------------------------------------+
#| c77d683d-8794-40e0-a263-f123cc2b82d5 | ISPN         | 10.172.226.194 | 2023-06-13 14:19:06 | 0x02A263F123CC2B82D5C77D683D879440E0030100126339383166386139613633342D353336353910040AACE2C21E78FFFF |
#| 49982491-1810-42ca-bf21-1e4266488ee2 | ISPN         | 10.172.226.194 | 2023-06-13 22:54:29 | 0x02BF211E4266488EE249982491181042CA030100123533353562386336386237382D333935343610040AACE2C21E78FFFF |
#+--------------------------------------+--------------+----------------+---------------------+------------------------------------------------------------------------------------------------------+
#

ENTRYPOINT ["/opt/keycloak/bin/kc.sh","start"]