{ config, lib, pkgs, ... }:
let
  cfg = config.m1cr0man.monitoring;
  ports = cfg.ports;

  # Whether to enable the debug sink for reading logs
  debug = false;
in
{
  services.vector = {
    enable = true;
    journaldAccess = true;
    settings = {
      api.enabled = true;
      data_dir = "/var/lib/vector";
      sources = {
        # Keys here are just unique identifiers
        journald_local = {
          type = "journald";
          current_boot_only = true;
        };
        logs_local = lib.mkIf (cfg.logFiles != [])  {
          type = "file";
          include = cfg.logFiles;
          exclude = [
            "/var/log/btmp"
            "/var/log/btmp.1"
            "/var/log/journal/**/*"
            "/var/log/journal/*"
            "/var/log/lastlog"
            "/var/log/messages"
            "/var/log/private"
            "/var/log/warn"
            "/var/log/wtmp"
          ];
        };
        host_local = lib.mkIf (cfg.hostMetrics) {
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
          endpoint = cfg.lokiAddress;
          batch.timeout_secs = 10;
          compression = "gzip";
          encoding = {
            except_fields = ["labels"];
            codec = "json";
          };
        };
        log_files_loki = lib.mkIf (cfg.logFiles != []) {
          type = "loki";
          inputs = [ "logs_local" ];
          remove_label_fields = true;
          labels = {
            transport = "{{ source_type }}";
            host = "{{ host }}";
            file = "{{ file }}";
          };
          endpoint = cfg.lokiAddress;
          batch.timeout_secs = 10;
          compression = "gzip";
          encoding = {
            except_fields = ["labels"];
            codec = "json";
          };
        };
        prom = lib.mkIf (cfg.hostMetrics) {
          type = "prometheus_exporter";
          address = "0.0.0.0:9136";
          inputs = [ "host_local" ];
          buffer.max_size = 1048576 * 16;
          buffer.type = "memory";
        };
      };
    };
  };
}
