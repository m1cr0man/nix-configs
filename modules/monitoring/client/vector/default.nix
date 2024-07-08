{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.monitoring;
  ports = cfg.ports;
  systemctl = "${config.systemd.package}/bin/systemctl";

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
    "NextElapseUSecRealtime" "LastTriggerUSec"
  ]);

  # Whether to enable the debug sink for reading logs
  debug = true;
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
        # systemd_local_common = {
        #   type = "exec";
        #   mode = "scheduled";
        #   scheduled.exec_interval_secs = 60;
        #   decoding.vrl.source = ./systemd.vrl;
        #   command = "${systemctl} show --no-pager --timestamp=unix --type mount,socket,target -p ${commonPropsArg}";
        # };
        systemd_local_services = {
          type = "exec";
          mode = "scheduled";
          scheduled.exec_interval_secs = 5;
          framing.method = "bytes";
          include_stderr = false;
          decoding.codec = "vrl";
          decoding.vrl.source = builtins.readFile ./systemd.vrl;
          command = [
            systemctl
            "show"
            "--no-pager"
            "--timestamp=unix"
            "--type=scope,service,slice"
            "-p"
            servicePropsArg
          ];
        };
        # systemd_local_timers = {
        #   type = "exec";
        #   mode = "scheduled";
        #   scheduled.exec_interval_secs = 60;
        #   decoding.vrl.source = ./systemd.vrl;
        #   command = "${systemctl} show --no-pager --timestamp=unix --type timer -p ${timerPropsArg}";
        # };
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
          inputs = [ "systemd_local_services" ];
          all_metrics = true;
          metrics = [];
          # metrics = [{
          #   type = "set";
          #   field = "message";
          #   namespace = "systemd";
          #   tags = {};
          # }];
        };
        # systemd_parse = {
        #   type = "remap";
        #   inputs = [ "systemd_local_services" ];
        #   source = builtins.readFile ./systemd.vrl;
        # };
      };
      sinks = {
        # debug = lib.mkIf debug {
        #   type = "file";
        #   inputs = [ "systemd_parse" ];
        #   path = "/var/lib/vector/vector-%Y-%m-%d.log";
        #   encoding = {
        #     codec = "json";
        #   };
        # };
        journald_loki = {
          type = "loki";
          inputs = [ "journald_sanitize" ];
          labels."*" = "{{ labels }}";
          endpoint = cfg.loki_address;
          batch.timeout_secs = 10;
          compression = "gzip";
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
