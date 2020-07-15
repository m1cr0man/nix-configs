{ pkgs, config, ... }:
let
  secrets = import ../../common/secrets.nix;

  host = "127.0.0.1";
  port = 8888;
  vhost = "chronograf.m1cr0man.com";
in {
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

  security.acme.certs."m1cr0man.com".extraDomainNames = [ vhost ];
  services.httpd.virtualHosts."${vhost}" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = ''
      <Proxy *>
        AuthType Basic
        AuthName "Login to Chronograf"
        AuthUserFile "${pkgs.writeText "chronograf-htpasswd" secrets.generic_htpasswd}"
        Require valid-user
      </Proxy>

      ProxyPass / http://${host}:${toString port}/
    '';
  };
}
