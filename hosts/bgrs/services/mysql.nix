{ pkgs, ... }:
let
  pkg = pkgs.mariadb;
  secrets = import ../../../common/secrets.nix;
in {
  services.mysql = {
    enable = true;
    package = pkg;
    ensureDatabases = [ "bgrs" ];
    ensureUsers = [
      {
        name = "wwwrun";
        ensurePermissions = {
          "bgrs.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.mysql-backup = let
    parent = [ "mysql.service" ];
  in {
    description = "Peform mysqldump before shutdown";
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
      zip -4 -e -P '${secrets.bgrs_zip_password}' $STATE_DIRECTORY/$FNAME.zip $FNAME.sql
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
    };
  };
}
