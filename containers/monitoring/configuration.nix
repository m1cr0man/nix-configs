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
    ];

  system.stateVersion = "24.05";

  nixosContainer =
    {
      forwardPorts =
        builtins.map
          (port: { hostPort = port; containerPort = port; })
          [
            config.services.prometheus.port
            config.services.loki.configuration.server.http_listen_port
            config.services.grafana.settings.server.http_port
          ];
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
    config.services.grafana.settings.server.http_port
  ];

  # Force monitoring stack to forward to localhost
  m1cr0man.monitoring = let
    ports = config.m1cr0man.monitoring.ports;
  in {
    lokiAddress = "http://localhost:${builtins.toString ports.loki}";
    prometheusAddress = "http://localhost:${builtins.toString ports.prometheus}";
  };
}
