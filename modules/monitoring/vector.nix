{ config, ... }:
let
  ports = config.m1cr0man.monitoring.ports;
in
{
  services.vector = {
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
        host_local = {
          type = "host_metrics";
          collectors = [
            "cpu"
            "filesystem"
            "load"
            "memory"
            "network"
          ];
        };
      };
      sinks = {
        loki = {
          type = "loki";
          inputs = [ "journald_local" ];
          labels = {
            host = "{{ .host }}";
            level = "{{ .level }}";
            identifier = "{{ .SYSLOG_IDENTIFIER }}";
          };
          endpoint = "http://localhost:${builtins.toString ports.loki}";
          batch.timeout_secs = 10;
          encoding.codec = "logfmt";
        };
        prom = {
          type = "prometheus_exporter";
          inputs = [ "host_local" ];
          address = "127.0.0.1:${builtins.toString ports.vector_prom}";
        };
      };
    };
  };
}
