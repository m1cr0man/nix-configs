{ config, pkgs, lib, ... }:
let
  pkg = pkgs.postgresql_13;
in
{
  services.postgresql = {
    enable = true;
    package = pkg;
    ensureDatabases = [ "dbbrb" "dbdomains" "dbpml" "repairs" ];
    ensureUsers = [
      {
        name = "wwwrun";
        ensurePermissions = {
          "DATABASE dbbrb" = "ALL PRIVILEGES";
          "DATABASE dbdomains" = "ALL PRIVILEGES";
          "DATABASE dbpml" = "ALL PRIVILEGES";
          "DATABASE repairs" = "ALL PRIVILEGES";
        };
      }
    ];
    enableTCPIP = true;
    authentication = ''
      host all all 192.168.0.0/16 md5
      host all all 192.168.0.0/16 scram-sha-256
      host all all 192.168.0.0/16 password
      host all all 10.88.0.0/16 md5
      host all all 10.88.0.0/16 scram-sha-256
      host all all 10.88.0.0/16 password
    '';
    settings = {
      log_connections = true;
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";
    };
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];

  systemd.services.postgresql-backup =
    let
      parent = [ "postgresql.service" ];
    in
    {
      description = "Perform pg_dumpall before shutdown";
      # Start with postgresql
      wantedBy = parent;
      # Stop with postgresql
      partOf = parent;
      # Start after/stop before postgresql
      after = parent;
      path = [ pkg pkgs.zip ];
      script = "true";
      preStop = ''
        FNAME="postgresqldump-$(date +'%F')"
        pg_dumpall > $FNAME.sql
        zip -4 -e -P "$ZIP_PASSWORD" $STATE_DIRECTORY/$FNAME.zip $FNAME.sql
        rm $FNAME.sql
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "postgresql_backup";
        WorkingDirectory = "/tmp";
        EnvironmentFile = config.sops.secrets.bgrs_passwords_env.path;
        PrivateTmp = true;
        User = "postgres";
        Group = "postgres";
      };
    };

  sops.secrets.bgrs_passwords_env = { };
}
