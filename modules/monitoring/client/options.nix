{ config, lib, ... }:
let
  cfg = config.m1cr0man.monitoring;
  defaultHost = if config.m1cr0man.instanceType == "container" then "containerhost.local" else "localhost";
in
{
  options.m1cr0man.monitoring.loki_address = lib.mkOption {
    default = "http://${defaultHost}:${builtins.toString cfg.ports.loki}";
    type = lib.types.str;
    description = "Address of Loki server";
  };
  options.m1cr0man.monitoring.prometheus_address = lib.mkOption {
    default = "http://${defaultHost}:${builtins.toString cfg.ports.prometheus}";
    type = lib.types.str;
    description = "Address of Prometheus server";
  };
}
