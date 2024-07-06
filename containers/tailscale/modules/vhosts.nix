{ domain, config, lib, pkgs, ... }:
let
  tsDomain = "ts.${domain}";
  makeVhostProxy = { useACMEHost ? tsDomain, ... }@args:
    (lib.m1cr0man.makeVhostProxy (args)) // { inherit useACMEHost; };
in
{
  services.httpd.virtualHosts = {
    "grafana.${tsDomain}" = makeVhostProxy { host = "containerhost.local:8030"; };
  };
}
