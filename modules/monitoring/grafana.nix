{ config, domain, ... }:
{
  sops.secrets.grafana_admin_password.owner = config.systemd.services.grafana.serviceConfig.User;
  sops.secrets.grafana_secret_key.owner = config.systemd.services.grafana.serviceConfig.User;

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
  };
}
