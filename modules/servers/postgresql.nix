{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.postgresql;

  package = cfg.package;
  startupScript = pkgs.writeText "postgres-startup-commands" cfg.startupCommands;
in
{
  options.m1cr0man.postgresql = with lib; {
    startupCommands = mkOption {
      default = "";
      type = types.lines;
      description = "Commands to run on each startup of the database";
    };
    package = mkOption {
      default = pkgs.postgresql_13;
      type = types.path;
      description = ''
        PostgreSQL package to run. Note when upgrading major versions the
        data directory will change + migration must be performed.
      '';
    };
  };

  config = {
    systemd.services.postgresql-startup-commands = {
      wantedBy = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      description = "Runs database scripts on each postgres startup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${package}/bin/psql -d postgres -f '${startupScript}'";
      };
    };

    services.postgresql = {
      enable = true;
      # On first startup, it will be necessary to run the startupScript early.
      # It doesn't hurt that it'll run twice - it should be idempotent.
      initialScript = startupScript;
      inherit package;
    };
  };
}
