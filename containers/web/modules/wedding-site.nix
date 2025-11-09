{ pkgs, lib, config, ... }:
{
  m1cr0man.imhumane-rs = {
    enable = true;
    listenerAddress = "127.0.0.1:8087";
    imageConfig.imagesDirectory = "/var/lib/imhumane-rs/images";
  };

  sops.secrets.rsvp_saver_env_config = {};

  systemd.services.rsvp-saver = {
    description = "Wedding RSVP Saver";
    wantedBy = [ "multi-user.target" ];
    environment = {
      DB_NAME = "wedding";
      DB_USERNAME = "wedding";
      DB_SOCKET_PATH = "/var/lib/sockets";
      ALLOWED_ORIGIN = "https://meghan-and-lucas.wedding";
      CAPTCHA_VALIDATION_URL = "http://localhost:8087/v1/tokens/validate/json";
      RUST_LOG = "info";
    };
    serviceConfig = {
      ExecStart = "${pkgs.m1cr0man.rsvp-saver}/bin/rsvp-saver";
      Restart = "always";
      RestartSec = 5;
      EnvironmentFile = config.sops.secrets.rsvp_saver_env_config.path;
    };
  };
}
