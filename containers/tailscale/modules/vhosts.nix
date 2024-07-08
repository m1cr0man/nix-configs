{ domain, config, lib, pkgs, ... }:
let
  tsDomain = "ts.${domain}";
  makeVhostProxy = { useACMEHost ? tsDomain, ... }@args:
    (lib.m1cr0man.makeVhostProxy (args)) // { inherit useACMEHost; };
in
{
  m1cr0man.monitoring.logFiles = [
    "/var/log/httpd/*.log"
  ];

  systemd.services.vector.serviceConfig.SupplementaryGroups = lib.mkForce [
    "wwwrun"
    "systemd-journal"
  ];

  services.httpd.virtualHosts = {
    "grafana.${tsDomain}" = makeVhostProxy { host = "containerhost.local:8030"; };
  };
}
