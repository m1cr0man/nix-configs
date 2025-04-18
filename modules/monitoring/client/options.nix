{ config, lib, ... }:
let
  cfg = config.m1cr0man.monitoring;
in
{
  options.m1cr0man.monitoring = {
    serverHostname = lib.mkOption {
      # mdns/search domain resolution
      default = "monitoring";
      type = lib.types.str;
      description = "Monitoring server host name.";
    };
    lokiAddress = lib.mkOption {
      default = "http://${cfg.serverHostname}:${builtins.toString cfg.ports.loki}";
      type = lib.types.str;
      description = "Address of Loki server";
    };
    prometheusAddress = lib.mkOption {
      default = "http://${cfg.serverHostname}:${builtins.toString cfg.ports.prometheus}";
      type = lib.types.str;
      description = "Address of Prometheus server";
    };
    hostMetrics = lib.mkEnableOption "read cpu, load, memory and network metrics";
    logFiles = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.path;
      description = "Paths to log files to send to Loki";
    };
  };
}
