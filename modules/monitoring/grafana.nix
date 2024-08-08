{ config, domain, ... }:
let
  user = config.systemd.services.grafana.serviceConfig.User;
in
{
  sops.secrets.grafana_admin_password.owner = user;
  sops.secrets.grafana_secret_key.owner = user;
  sops.secrets.sysmail_password.owner = user;

  systemd.services.grafana.serviceConfig.StateDirectory = "grafana";

  services.grafana = {
    enable = true;
    settings.log = {
      mode = "console";
      level = "warn";
    };
    settings."log.console".format = "json";
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = 8030;
      enable_gzip = true;
      inherit domain;
    };
    settings.security = {
      admin_user = "admin";
      admin_password = "\$__file{${config.sops.secrets.grafana_admin_password.path}}";
      secret_key = "\$__file{${config.sops.secrets.grafana_secret_key.path}}";
    };
    settings.smtp = {
      enabled = true;
      host = "mail.m1cr0man.com:587";
      startTLS_policy = "MandatoryStartTLS";
      user = "sysmail@m1cr0man.com";
      password = "\$__file{${config.sops.secrets.sysmail_password.path}}";
      from_user = "Grafana";
      from_address = "sysmail+grafana@m1cr0man.com";
    };
  };
}
