FROM quay.io/keycloak/keycloak:21.1.1

ENV KC_DB=database_vendor
ENV KC_DB_USERNAME=username
ENV KC_DB_PASSWORD=password
ENV KC_DB_SCHEMA=database_name
ENV KC_DB_URL_HOST=database_host
ENV KC_DB_URL=jdbc:database_vendor://database_host/database_name

COPY cache-ispn-jdbc-ping.xml /opt/keycloak/conf/cache-ispn-jdbc-ping.xml

ENV KC_CACHE_CONFIG_FILE=cache-ispn-jdbc-ping.xml
