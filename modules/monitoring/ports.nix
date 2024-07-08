{ config, lib, ... }:
with lib;
with types;
{
  options.m1cr0man.monitoring.ports = {
    prometheus = mkOption {
      type = int;
      default = config.services.prometheus.port;
      readOnly = true;
      description = "Prometheus API port";
    };
    loki = mkOption {
      type = int;
      default = 8035;
      description = "Loki API port";
    };
  };
}
