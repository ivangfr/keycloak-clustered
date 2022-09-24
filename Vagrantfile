# -- PARAMETERS --------------------------------------------------------------------------------------------------------

     DISCOVERY_PROTOCOL = "JDBC_PING"
     BUILD_DOCKER_IMAGE = false        # Options: true | false
    BUILD_IMAGE_VERSION = "19.0.2"
# ---
         KEYCLOAK_ADMIN = "admin"
KEYCLOAK_ADMIN_PASSWORD = "admin"
                  KC_DB = "mysql"      # Options: "mysql" | "mariadb" | "postgres"
     KC_DB_URL_DATABASE = "keycloak"
           KC_DB_SCHEMA = ""
         KC_DB_USERNAME = "keycloak"
         KC_DB_PASSWORD = "password"
           KC_LOG_LEVEL = "INFO,org.infinispan:DEBUG,org.jgroups:DEBUG"

# ----------------------------------------------------------------------------------------------------------------------

BOX_IMAGE = "hashicorp/bionic64"

KC_DB_PORTS = { "mysql" => 3306, "mariadb" => 3307, "postgres" => 5432 }

DATABASE_IP = "10.0.0.10"
KEYCLOAK_1_IP = "10.0.0.11"
KEYCLOAK_2_IP = "10.0.0.12"

KEYCLOAK_CLUSTERED_DOCKER_IMAGE = "ivanfranchin/keycloak-clustered:#{BUILD_IMAGE_VERSION}"

KEYCLOAK_CLUSTERED_CONTAINER_ARGS = "-p 8080:8080 -p 7800:7800 -p 8443:8443 -e KEYCLOAK_ADMIN=#{KEYCLOAK_ADMIN} -e KEYCLOAK_ADMIN_PASSWORD=#{KEYCLOAK_ADMIN_PASSWORD} -e KC_DB=#{KC_DB} -e KC_DB_URL_HOST=#{DATABASE_IP}:#{KC_DB_PORTS[KC_DB]} -e KC_DB_URL_DATABASE=#{KC_DB_URL_DATABASE} -e KC_DB_USERNAME=#{KC_DB_USERNAME} -e KC_DB_PASSWORD=#{KC_DB_PASSWORD} -e KC_LOG_LEVEL=#{KC_LOG_LEVEL}"

if KC_DB_SCHEMA != ""
  KEYCLOAK_CLUSTERED_CONTAINER_ARGS += " -e KC_DB_SCHEMA=#{KC_DB_SCHEMA}"
end

KEYCLOAK_CLUSTERED_1_CONTAINER_ARGS = KEYCLOAK_CLUSTERED_CONTAINER_ARGS
KEYCLOAK_CLUSTERED_2_CONTAINER_ARGS = KEYCLOAK_CLUSTERED_CONTAINER_ARGS

KEYCLOAK_CLUSTERED_1_CONTAINER_ARGS += " -e JGROUPS_DISCOVERY_EXTERNAL_IP=#{KEYCLOAK_1_IP}"
KEYCLOAK_CLUSTERED_2_CONTAINER_ARGS += " -e JGROUPS_DISCOVERY_EXTERNAL_IP=#{KEYCLOAK_2_IP}"

# ----------------------------------------------------------------------------------------------------------------------

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE

  config.vm.define "databases" do |v|
    v.vm.box = BOX_IMAGE
    v.vm.network "private_network", ip: DATABASE_IP
    v.vm.provision "docker" do |d|
      d.run "mysql",
        image: "mysql:5.7.39",
        args: "-p 3306:3306 -e MYSQL_DATABASE=#{KC_DB_URL_DATABASE} -e MYSQL_USER=#{KC_DB_USERNAME} -e MYSQL_PASSWORD=#{KC_DB_PASSWORD} -e MYSQL_ROOT_PASSWORD=root_password"

      d.run "mariadb",
        image: "mariadb:10.9.2",
        args: "-p 3307:3306 -e MYSQL_DATABASE=#{KC_DB_URL_DATABASE} -e MYSQL_USER=#{KC_DB_USERNAME} -e MYSQL_PASSWORD=#{KC_DB_PASSWORD} -e MYSQL_ROOT_PASSWORD=root_password"

      d.run "postgres",
        image: "postgres:14.5",
        args: "-p 5432:5432 -e POSTGRES_DB=#{KC_DB_URL_DATABASE} -e POSTGRES_USER=#{KC_DB_USERNAME} -e POSTGRES_PASSWORD=#{KC_DB_PASSWORD}"
    end
  end

  config.vm.define "keycloak1" do |v|
    v.vm.box = BOX_IMAGE
    v.vm.network "private_network", ip: KEYCLOAK_1_IP
    v.vm.network "forwarded_port", guest: 8080, host: 8080
    v.vm.provision "docker" do |d|
      if BUILD_DOCKER_IMAGE == true
        d.build_image "/vagrant/#{BUILD_IMAGE_VERSION}",
          args: "-t #{KEYCLOAK_CLUSTERED_DOCKER_IMAGE}"
      end
      d.run "keycloak-clustered",
        image: KEYCLOAK_CLUSTERED_DOCKER_IMAGE,
        args: KEYCLOAK_CLUSTERED_1_CONTAINER_ARGS,
        cmd: "start-dev"
    end
  end

  config.vm.define "keycloak2" do |v|
    v.vm.box = BOX_IMAGE
    v.vm.network "private_network", ip: KEYCLOAK_2_IP
    v.vm.network "forwarded_port", guest: 8080, host: 8081
    v.vm.provision "docker" do |d|
      if BUILD_DOCKER_IMAGE == true
        d.build_image "/vagrant/#{BUILD_IMAGE_VERSION}",
          args: "-t #{KEYCLOAK_CLUSTERED_DOCKER_IMAGE}"
      end
      d.run "keycloak-clustered",
        image: KEYCLOAK_CLUSTERED_DOCKER_IMAGE,
        args: KEYCLOAK_CLUSTERED_2_CONTAINER_ARGS,
        cmd: "start-dev"
    end
  end

end