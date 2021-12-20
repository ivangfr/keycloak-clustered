# -- PARAMETERS --------------------------------------------------------------------------------------------------------

 DISCOVERY_PROTOCOL = "JDBC_PING"  # Options: "JDBC_PING" | "TCPPING"
 BUILD_DOCKER_IMAGE = false        # Options: true | false
BUILD_IMAGE_VERSION = "16.1.0"
# ---
      KEYCLOAK_USER = "admin"
  KEYCLOAK_PASSWORD = "admin"    
          DB_VENDOR = "mysql"      # Options: "mysql" | "mariadb" | "postgres"
        DB_DATABASE = "keycloak"
          DB_SCHEMA = ""
            DB_USER = "keycloak"
        DB_PASSWORD = "password"
        JDBC_PARAMS = "useSSL=false"

# ----------------------------------------------------------------------------------------------------------------------

BOX_IMAGE = "hashicorp/bionic64"

DB_PORTS = { "mysql" => 3306, "mariadb" => 3307, "postgres" => 5432 }

DATABASE_IP = "10.0.0.10"
KEYCLOAK_1_IP = "10.0.0.11"
KEYCLOAK_2_IP = "10.0.0.12"

KEYCLOAK_CLUSTERED_DOCKER_IMAGE = "ivanfranchin/keycloak-clustered:latest"

KEYCLOAK_CLUSTERED_CONTAINER_ARGS = "-p 8080:8080 -p 7600:7600 -p 8443:8443 -e KEYCLOAK_USER=#{KEYCLOAK_USER} -e KEYCLOAK_PASSWORD=#{KEYCLOAK_PASSWORD} -e DB_VENDOR=#{DB_VENDOR} -e DB_ADDR=#{DATABASE_IP} -e DB_PORT=#{DB_PORTS[DB_VENDOR]} -e DB_USER=#{DB_USER} -e DB_PASSWORD=#{DB_PASSWORD} -e JDBC_PARAMS=#{JDBC_PARAMS}"

if DB_SCHEMA != ""
  KEYCLOAK_CLUSTERED_CONTAINER_ARGS += " -e DB_SCHEMA=#{DB_SCHEMA}"
end

KEYCLOAK_CLUSTERED_1_CONTAINER_ARGS = KEYCLOAK_CLUSTERED_CONTAINER_ARGS
KEYCLOAK_CLUSTERED_2_CONTAINER_ARGS = KEYCLOAK_CLUSTERED_CONTAINER_ARGS

if DISCOVERY_PROTOCOL == "JDBC_PING"
  DISCOVERY_PROPERTIES = "datasource_jndi_name=java:jboss/datasources/KeycloakDS"
else
  DISCOVERY_PROPERTIES = "initial_hosts=\"#{KEYCLOAK_1_IP}[7600],#{KEYCLOAK_2_IP}[7600]\""
end
KEYCLOAK_CLUSTERED_1_CONTAINER_ARGS += " -e JGROUPS_DISCOVERY_EXTERNAL_IP=#{KEYCLOAK_1_IP} -e JGROUPS_DISCOVERY_PROTOCOL=#{DISCOVERY_PROTOCOL} -e JGROUPS_DISCOVERY_PROPERTIES=#{DISCOVERY_PROPERTIES}"
KEYCLOAK_CLUSTERED_2_CONTAINER_ARGS += " -e JGROUPS_DISCOVERY_EXTERNAL_IP=#{KEYCLOAK_2_IP} -e JGROUPS_DISCOVERY_PROTOCOL=#{DISCOVERY_PROTOCOL} -e JGROUPS_DISCOVERY_PROPERTIES=#{DISCOVERY_PROPERTIES}"

# ----------------------------------------------------------------------------------------------------------------------

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE

  config.vm.define "databases" do |v|
    v.vm.box = BOX_IMAGE
    v.vm.network :private_network, ip: DATABASE_IP
    v.vm.provision "docker" do |d|
      d.run "mysql",
        image: "mysql:5.7.36",
        args: "-p 3306:3306 -e MYSQL_DATABASE=#{DB_DATABASE} -e MYSQL_USER=#{DB_USER} -e MYSQL_PASSWORD=#{DB_PASSWORD} -e MYSQL_ROOT_PASSWORD=root_password"

      d.run "mariadb",
        image: "mariadb:10.6.5",
        args: "-p 3307:3306 -e MYSQL_DATABASE=#{DB_DATABASE} -e MYSQL_USER=#{DB_USER} -e MYSQL_PASSWORD=#{DB_PASSWORD} -e MYSQL_ROOT_PASSWORD=root_password"

      d.run "postgres",
        image: "postgres:14.1",
        args: "-p 5432:5432 -e POSTGRES_DB=#{DB_DATABASE} -e POSTGRES_USER=#{DB_USER} -e POSTGRES_PASSWORD=#{DB_PASSWORD}"
    end
  end

  config.vm.define "keycloak1" do |v|
    v.vm.box = BOX_IMAGE
    v.vm.network :private_network, ip: KEYCLOAK_1_IP
    v.vm.network "forwarded_port", guest: 8080, host: 8080
    v.vm.provision "docker" do |d|
      if BUILD_DOCKER_IMAGE == true
        d.build_image "/vagrant/#{BUILD_IMAGE_VERSION}",
          args: "-t #{KEYCLOAK_CLUSTERED_DOCKER_IMAGE}"
      end
      d.run "keycloak-clustered",
        image: KEYCLOAK_CLUSTERED_DOCKER_IMAGE,
        args: KEYCLOAK_CLUSTERED_1_CONTAINER_ARGS
    end
  end

  config.vm.define "keycloak2" do |v|
    v.vm.box = BOX_IMAGE
    v.vm.network :private_network, ip: KEYCLOAK_2_IP
    v.vm.network "forwarded_port", guest: 8080, host: 8081
    v.vm.provision "docker" do |d|
      if BUILD_DOCKER_IMAGE == true
        d.build_image "/vagrant/#{BUILD_IMAGE_VERSION}",
          args: "-t #{KEYCLOAK_CLUSTERED_DOCKER_IMAGE}"
      end
      d.run "keycloak-clustered",
        image: KEYCLOAK_CLUSTERED_DOCKER_IMAGE,
        args: KEYCLOAK_CLUSTERED_2_CONTAINER_ARGS
    end
  end

end
