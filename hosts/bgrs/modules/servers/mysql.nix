{ config, pkgs, ... }:
let
  pkg = pkgs.mariadb;
in
{
  services.mysql = {
    enable = true;
    package = pkg;
    ensureDatabases = [ "bgrs" "akaunting" ];
    ensureUsers = [
      {
        name = "wwwrun";
        ensurePermissions = {
          "bgrs.*" = "ALL PRIVILEGES";
          "akaunting.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.mysql-backup =
    let
      parent = [ "mysql.service" ];
    in
    {
      description = "Perform mysqldump before shutdown";
      # Start with mysql
      wantedBy = parent;
      # Stop with mysql
      partOf = parent;
      # Start after/stop before mysql
      after = parent;
      path = [ pkg pkgs.zip ];
      script = "true";
      preStop = ''
        FNAME="mysqldump-$(date +'%F')"
        mysqldump --flush-privileges --single-transaction --comments --hex-blob -A > $FNAME.sql
        zip -4 -e -P "$ZIP_PASSWORD" $STATE_DIRECTORY/$FNAME.zip $FNAME.sql
        rm $FNAME.sql
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "mysql_backup";
        WorkingDirectory = "/tmp";
        PrivateTmp = true;
        User = "mysql";
        Group = "mysql";
        EnvironmentFile = config.sops.secrets.bgrs_passwords_env.path;
      };
    };

  sops.secrets.bgrs_passwords_env = { };
}
