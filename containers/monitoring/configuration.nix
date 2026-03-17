{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/client"
      "monitoring/ports.nix"
      "monitoring/prometheus.nix"
      "monitoring/loki.nix"
      "monitoring/grafana.nix"
      "www/acme-base.nix"
      "www/httpd.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "25.11";

  nixosContainer =
    {
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/prometheus:/var/lib/prometheus"
        "${stateDir}/loki:/var/lib/loki"
        "${stateDir}/grafana:/var/lib/grafana"
      ];
    };

  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.port
    config.services.loki.configuration.server.http_listen_port
  ];
}
