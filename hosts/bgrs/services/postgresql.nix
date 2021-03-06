{ pkgs, ... }:
let
  pkg = pkgs.postgresql_13;
  secrets = import ../../../common/secrets.nix;
in {
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
  };

  systemd.services.postgresql-backup = let
    parent = [ "postgresql.service" ];
  in {
    description = "Peform pg_dumpall before shutdown";
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
      zip -4 -e -P '${secrets.bgrs_zip_password}' $STATE_DIRECTORY/$FNAME.zip $FNAME.sql
      rm $FNAME.sql
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
