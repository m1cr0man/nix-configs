{ lib, ... }:
with lib;
with types;
{
  options.m1cr0man.monitoring.ports = {
    vector_prom = mkOption {
      type = int;
      default = 9100;
      description = "Vector Prometheus exporter port";
    };
    loki = mkOption {
      type = int;
      default = 8035;
      description = "Loki listening port";
    };
  };
}
