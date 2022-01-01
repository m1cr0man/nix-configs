{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.chronograf;

  secretPath = sops.secrets."${config.m1cr0man.webserver.htpasswdSecret}".path;
  host = if cfg.reverseProxy then "127.0.0.1" else "0.0.0.0";
  port = 8888;
  vhost = "chronograf.m1cr0man.com";
in
{
  options.m1cr0man.chronograf = with lib; {
    reverseProxy = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = {
    imports = [ ../../packages/chronograf/config.nix ];

    services.chronograf = {
      inherit host port;
      enable = true;
      package = import ../../packages/chronograf { inherit pkgs; };
      dataDir = "/var/lib/tick/chronograf";
      user = "influxdb";
      group = "influxdb";
      logLevel = "error";
      influxdb = {
        url = "http://${config.services.influxdb.extraConfig.http.bind-address}";
      };
      kapacitor = {
        url = "http://${config.services.kapacitor.bind}:${toString config.services.kapacitor.port}";
      };
    };

    networking.firewall.allowedTCPPorts = lib.optionals (!config.m1cr0man.chronograf.reverseProxy) [ port ];

    services.httpd = lib.optionalAttrs (config.m1cr0man.chronograf.reverseProxy) {
      virtualHosts."${vhost}" = lib.m1cr0man.makeVhostProxy {
        host = "${host}:${toString port}";
        extraConfig = ''
          <Proxy *>
            AuthType Basic
            AuthName "Login to Chronograf"
            AuthUserFile "${secretPath}"
            Require valid-user
          </Proxy>
        '';
      };
    };
  };
}
