{ pkgs, config, ... }:
{
  sops.secrets.rsvp_manager_env_config = {};

  systemd.services.rsvp-manager = {
    description = "Wedding RSVP manager";
    wantedBy = [ "multi-user.target" ];
    environment = {
      WEDDING_DB_NAME = "wedding";
      WEDDING_DB_USER = "wedding";
      WEDDING_DB_SOCKET = "/var/lib/sockets";
    };
    serviceConfig = {
      ExecStart = "${pkgs.m1cr0man.rsvp-manager}/bin/rsvp-manager";
      Restart = "always";
      RestartSec = 5;
      KillSignal = "SIGKILL";
      EnvironmentFile = config.sops.secrets.rsvp_manager_env_config.path;
    };
  };
}
