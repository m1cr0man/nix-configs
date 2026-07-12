{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.monitoring.machinectl-prom-sd;
  bin = "${pkgs.m1cr0man.scripts}/bin/machinectl-prom-sd";
  portsArg = lib.concatMapStringsSep "," toString cfg.ports;
in
{
  options.m1cr0man.monitoring.machinectl-prom-sd = {
    enable = lib.mkEnableOption "machinectl-based Prometheus file_sd generator";
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      description = "TCP ports to probe on each machine.";
    };
    interval = lib.mkOption {
      type = lib.types.str;
      default = "1m";
      description = "How often to regenerate the target list (systemd time span).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.machinectl-prom-sd = {
      description = "Generate Prometheus file_sd JSON from machinectl";
      requisite = [ "machines.target" ];
      path = [ config.systemd.package ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${bin} %S/containers/monitoring/prometheus2/machinectl-prom-sd/machinectl.json --ports=${portsArg}";
        StateDirectory = "containers/monitoring/prometheus2/machinectl-prom-sd";
      };
    };

    systemd.timers.machinectl-prom-sd = {
      description = "Periodically regenerate machinectl Prometheus targets";
      wantedBy = [ "timers.target" ];
      after = [ "machines.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "5s";
      };
    };
  };
}
