FROM quay.io/keycloak/keycloak:17.0.0

COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml

ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml

USER root

RUN microdnf install -y hostname

RUN sed -i '1 a export JGROUPS_DISCOVERY_EXTERNAL_IP=$(hostname -i)' /opt/keycloak/bin/kc.sh

USER keycloak
