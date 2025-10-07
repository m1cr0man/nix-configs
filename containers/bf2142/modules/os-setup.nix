{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.openspy-containers.stateDir;

  src = pkgs.fetchFromGitHub {
    owner = "openspy";
    repo = "openspy-web-backend";
    rev = "18dc7ea5578f95905ca7531aa09f275dbff3d320";
    hash = "sha256-AawEO1CHa+gaeoLrTc1n64EkNBZTMjIizXFuSbAh5Sk=";
    fetchSubmodules = true;
  };
  fixedImportScript = pkgs.runCommand "seeder.sh" {
    buildInputs = [ pkgs.gnused ];
  } ''
    sed 's!/sql/!!g;s!^sleep 10!set -x!g' ${src}/sql/import.sh > $out
  '';
in
{
  systemd.services.openspy-setup = {
    description = "Set up OpenSpy keys and static content";
    # requireBy podman so that the resources are created before any containers start
    requiredBy = [ "podman.service" ];
    before = [ "podman.service" ];
    requires = [ "rabbitmq.service" ];
    after = [ "rabbitmq.service" ];
    path = [ pkgs.openssl pkgs.gnused pkgs.rabbitmqadmin-ng pkgs.minica ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = stateDir;
      StateDirectory = lib.removePrefix "/var/lib/" stateDir;
      UMask = "0077";
      User = "openspy";
      Group = "openspy";
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      set -euxo pipefail
      if [[ ! -e openspy.local ]]; then
        minica --ca-key ca-key.pem --ca-cert ca-cert.pem --domains openspy.local
      fi
      if [[ ! -e openspy-auth-keys.env ]]; then
        printf "%s" $(openssl genrsa -out - -traditional 2048 | sed '/RSA PRIVATE KEY/d') > api-key.pkcs1
        printf "%s" $(openssl genrsa -out - -traditional 512  | sed '/RSA PRIVATE KEY/d') > preauth-key.pkcs1

        cat > openspy-auth-keys.env << EOF
      APIKeyPrivateKey=$(cat api-key.pkcs1)
      PresencePreAuthPrivateKey=$(cat preauth-key.pkcs1)
      EOF
      fi
      if [[ ! -e rabbitmq.env ]]; then
        RABBITMQ_PASSWORD=$(openssl rand -hex 16)
        # The management plugin runs on port 15672
        # Give it a few seconds to start up
        sleep 5
        rabbitmqadmin --host=localhost --port=15672 --username=guest --password=guest declare user --name=openspy --password="$RABBITMQ_PASSWORD" --tags=administrator
        rabbitmqadmin --host=localhost --port=15672 --username=guest --password=guest declare permissions --vhost=/ --user=openspy --configure='.*' --write='.*' --read='.*'
        rabbitmqadmin --host=localhost --port=15672 --username=openspy --password="$RABBITMQ_PASSWORD" delete user --name=guest

        cat > rabbitmq.env << EOF
      CONNECTIONSTRINGS__RMQCONNECTION=amqp://openspy:''${RABBITMQ_PASSWORD}@host.containers.internal:5672
      RABBITMQ_URL=amqp://openspy:''${RABBITMQ_PASSWORD}@host.containers.internal
      OPENSPY_AMQP_USER=openspy
      OPENSPY_AMQP_PASSWORD=''${RABBITMQ_PASSWORD}
      RABBITMQ_DEFAULT_USER=openspy
      RABBITMQ_DEFAULT_PASS=''${RABBITMQ_PASSWORD}
      EOF
      fi
      if [[ ! -e auth-services.private.pem ]]; then
        openssl genrsa -traditional -out auth-services.private.pem 2048
        openssl rsa -in auth-services.private.pem -RSAPublicKey_out -out auth-services.public.pem
      fi
      if [[ ! -e openspy-api-key.env ]]; then
        echo "Please generate the openspy API key"
        echo "It must contain HTTP_API_KEY, OPENSPY_API_KEY and API_KEY all set to the same value"
        exit 0
      fi
    '';
  };

  systemd.services.openspy-seeder = {
    description = "Initialize OpenSpy";
    requiredBy = [ "podman.service" ];
    before = [ "podman.service" ];
    requires = [ "openspy-setup.service" ];
    after = [ "openspy-setup.service" ];
    path = [ pkgs.mariadb pkgs.curl pkgs.python3 pkgs.rabbitmqadmin-ng ];
    environment = {
      MYSQL_USER = "openspy";
      # Intentionally unset (uses socket auth)
      MYSQL_PASSWORD = "";
      MYSQL_HOST = "localhost --socket /run/mysqld/mysqld.sock";
      HTTP_API_URL = "localhost:8080";
      RABBITMQ_HOST = "localhost";
      RABBITMQ_DEFAULT_VHOST = "/";
    };
    serviceConfig.EnvironmentFile = [ "${stateDir}/rabbitmq.env" "${stateDir}/openspy-api-key.env" ];
    serviceConfig = {
      WorkingDirectory = "${src}/sql";
      ExecStart = "${pkgs.bash}/bin/bash ${fixedImportScript}";
      User = "openspy";
      Group = "openspy";
      Restart = "no";
    };
  };
}
