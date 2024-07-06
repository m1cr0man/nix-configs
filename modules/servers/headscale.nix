{ pkgs, config, domain, lib, ... }:
let
  cfg = config.services.headscale;
in
{
  sops.secrets.headscale_database_password = {
    owner = cfg.user;
    group = cfg.group;
  };

  users.users.headscale.extraGroups = [ "sockets" ];
  users.users.headscale.uid = 850;
  users.groups.headscale.gid = 850;

  # Workaround for slow shutdown
  systemd.services.headscale.serviceConfig.TimeoutStopSec = 5;

  services.headscale = {
    enable = true;
    port = 51808;
    settings = {
      ip_prefixes = [
        "100.64.48.0/24"
        "fd7a:115c:a1e0:48::/64"
      ];
      server_url = "https://headscale.${domain}";
      dns_config.base_domain = "ts.${domain}";
      # Broken ATM, waiting for a fix.
      # https://github.com/juanfont/headscale/issues/764
      # db_type = "postgres";
      # db_user = "headscale";
      # db_name = "headscale";
      # db_password_file = config.sops.secrets.headscale_database_password.path;
      # # Confusing, but path is for sqlite
      # # And host is psql unix socket
      # db_path = null;
      # db_host = "/var/lib/sockets";
      # db_port = 5432;
    };
  };
}
