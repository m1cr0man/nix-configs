{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.monitoring;
  ports = cfg.ports;
  systemctlShow = [
    "${config.systemd.package}/bin/systemctl"
    "show"
    "--no-pager"
    "--timestamp=unix"
  ];

  commonProps = [
    "Id" "ActiveState" "SubState" "Result" "Slice"
    "StateChangeTimestamp"
  ];

  commonPropsArg = builtins.concatStringsSep "," commonProps;

  servicePropsArg = builtins.concatStringsSep "," (commonProps ++ [
    "CleanResult" "ControlPID" "CPUUsageNSec" "CPUQuotaPerSecUSec" "ExecMainPID"
    "IOReadBytes" "IOReadOperations" "IOWriteBytes" "IOWriteOperations" "IPEgressBytes"
    "IPEgressPackets" "IPIngressBytes" "IPIngressPackets" "MemoryAvailable" "MemoryCurrent"
    "MemoryLow" "MemoryMax" "MemoryMin" "MemoryPeak" "MemorySwapCurrent"
    "MemorySwapMax" "MemorySwapPeak" "MemoryZSwapCurrent" "MemoryZSwapMax" "ReloadResult"
    "TasksCurrent" "TasksMax"
  ]);

  timerPropsArg = builtins.concatStringsSep "," (commonProps ++ [
    # TODO open a bug in systemd because these are not unix formatted
    "NextElapseUSecRealtime" "LastTriggerUSec"
  ]);

  execOpts = {
    type = "exec";
    mode = "scheduled";
    framing.method = "bytes";
    include_stderr = false;
    decoding.codec = "vrl";
    decoding.vrl.source = builtins.readFile ./systemd.vrl;
  };

  # Whether to enable the debug sink for reading logs
  debug = false;
in
{
  options.m1cr0man.monitoring.host_metrics = lib.mkEnableOption "read cpu, load, memory and network metrics";

  config.services.vector = {
    enable = true;
    journaldAccess = true;
    settings = {
      data_dir = "/var/lib/vector";
      sources = {
        # Keys here are just unique identifiers
        journald_local = {
          type = "journald";
          current_boot_only = true;
          since_now = true;
        };
        systemd_local_common = execOpts // {
          scheduled.exec_interval_secs = 60;
          command = systemctlShow ++ [
            "--type=mount,socket,target"
            "-p"
            commonPropsArg
          ];
        };
        systemd_local_timers = execOpts // {
          scheduled.exec_interval_secs = 60;
          command = systemctlShow ++ [
            "--type=timer"
            "-p"
            timerPropsArg
          ];
        };
        systemd_local_services = execOpts // {
          scheduled.exec_interval_secs = 5;
          command = systemctlShow ++ [
            "--type=scope,service,slice"
            "-p"
            servicePropsArg
          ];
        };
        host_local = lib.mkIf (cfg.host_metrics) {
          type = "host_metrics";
          collectors = [
            "cpu"
            "load"
            "memory"
            "network"
          ];
        };
      };
      transforms = {
        journald_sanitize = {
          type = "remap";
          inputs = [ "journald_local" ];
          # TODO parse firewall logs
          source = builtins.readFile ./journald.vrl;
        };
        systemd_convert = {
          type = "log_to_metric";
          inputs = [
            "systemd_local_common"
            "systemd_local_timers"
            "systemd_local_services"
          ];
          all_metrics = true;
          metrics = [];
        };
      };
      sinks = {
        debug = lib.mkIf debug {
          type = "file";
          inputs = [ "journald_local" ];
          path = "/var/lib/vector/vector-%Y-%m-%d.log";
          encoding = {
            codec = "json";
          };
        };
        journald_loki = {
          type = "loki";
          inputs = [ "journald_sanitize" ];
          labels."*" = "{{ labels }}";
          endpoint = cfg.loki_address;
          batch.timeout_secs = 10;
          compression = "none";
          encoding = {
            except_fields = ["labels"];
            codec = "json";
          };
        };
        prom = {
          type = "prometheus_remote_write";
          inputs = [
            "systemd_convert"
          ] ++ (lib.optionals (cfg.host_metrics) [ "host_local" ]);
          endpoint = "${cfg.prometheus_address}/api/v1/write";
          # Healthcheck broken. See https://github.com/vectordotdev/vector/issues/8279
          healthcheck.enabled = false;
        };
      };
    };
  };
}
