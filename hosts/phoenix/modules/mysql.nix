{ config, pkgs, ... }:
let
  pkg = pkgs.mariadb;
  cfg = config.services.mysql;
in
{
  services.mysql = {
    enable = true;
    package = pkg;
    configFile = pkgs.writeText "my.cnf" ''
    [mysqld]
    datadir=${config.services.mysql.dataDir}
    skip-networking
    '';
  };

  systemd.services.mysql-backup = let
    parent = [ "mysql.service" ];
  in {
    description = "Perform mysqldump before shutdown";
    # Start with mysql
    wantedBy = parent;
    # Stop with mysql
    partOf = parent;
    # Start after/stop before mysql
    after = parent;
    path = [ pkg pkgs.zstd ];
    script = "true";
    preStop = ''
      mysqldump -p -A -R -E --flush-privileges --single-transaction --comments --hex-blob --tz-utc \
      | zstd -c5 - \
      > $STATE_DIRECTORY/mysqldump-$(date +'%F').sql.zst
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "mysql_backup";
      WorkingDirectory = "/tmp";
      PrivateTmp = true;
      User = cfg.user;
      Group = cfg.group;
    };
  };
}
