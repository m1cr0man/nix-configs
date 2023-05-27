{ config, pkgs, lib, ... }:
let
  pkg = pkgs.postgresql_16;
in
{
  services.postgresql = {
    enable = true;
    package = pkg;
    enableTCPIP = false;
    settings = {
      log_connections = true;
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";
      # _actually_ disable TCPIP and not just limit to localhost
      listen_addresses = lib.mkForce "";
    };
  };

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
      path = [ pkg pkgs.zstd ];
      script = "true";
      preStop = ''
        pg_dumpall \
        | zstd -c5 - \
        > STATE_DIRECTORY/postgresqldump-$(date +'%F').sql.zst
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "postgresql_backup";
        WorkingDirectory = "/tmp";
        PrivateTmp = true;
        User = "postgres";
        Group = "postgres";
      };
    };
}
