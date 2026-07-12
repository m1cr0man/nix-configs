{ config, pkgs, lib, ... }:
let
  stateDir = config.m1cr0man.container.stateDir;
in
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "secrets"
      "monitoring/prometheus.nix"
      "monitoring/loki.nix"
      "monitoring/grafana.nix"
      "www/acme-base.nix"
      "www/httpd.nix"
    ]
    ++
    addModulesRecursive ./modules;

  system.stateVersion = "26.11";

  nixosContainer =
    {
      bindMounts = [
        "${stateDir}/nixos:/var/lib/nixos"
        "${stateDir}/prometheus2:/var/lib/prometheus2"
        "${stateDir}/loki:/var/lib/loki"
        "${stateDir}/grafana:/var/lib/grafana"
      ];
    };

  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.port
    config.services.loki.configuration.server.http_listen_port
  ];

  services.prometheus.scrapeConfigs = [
    {
      job_name = "machinectl-prom-sd";
      file_sd_configs = [{
        files = [ "/var/lib/prometheus2/machinectl-prom-sd/machinectl.json" ];
      }];
    }
    {
      job_name = "systemd-exporterd";
      static_configs = [{
        targets = [
          "_gateway:9137"
        ];
      }];
    }
  ];
}
