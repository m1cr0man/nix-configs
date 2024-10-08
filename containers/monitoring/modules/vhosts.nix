{ domain, config, lib, pkgs, ... }:
let
  internalDomain = "int.${domain}";
  makeVhostProxy = { useACMEHost ? internalDomain, ... }@args:
    (lib.m1cr0man.makeVhostProxy (args)) // { inherit useACMEHost; };

  grafanaPort = builtins.toString config.services.grafana.settings.server.http_port;
in
{
  m1cr0man.monitoring.logFiles = [
    "/var/log/httpd/*.log"
  ];

  systemd.services.vector.serviceConfig.SupplementaryGroups = lib.mkForce [
    "wwwrun"
    "systemd-journal"
  ];

  systemd.services.httpd.serviceConfig = {
    LogsDirectory = "httpd";
    LogsDirectoryMode = 0755;
  };

  services.httpd.virtualHosts = {
    "monitoring.${internalDomain}" = (makeVhostProxy {
      host = "localhost:${grafanaPort}";
    }) // {
      serverAliases = [ "grafana.${internalDomain}" ];
    };
  };
}
