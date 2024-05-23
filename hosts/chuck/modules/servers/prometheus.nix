{ pkg, config, lib, domain, ... }:
{
  sops.secrets.grafana_admin_password.owner = config.systemd.services.grafana.serviceConfig.User;
  sops.secrets.grafana_secret_key.owner = config.systemd.services.grafana.serviceConfig.User;

  systemd.services.grafana.serviceConfig.StateDirectory = "grafana";

  services.grafana = {
    enable = true;
    settings.log = {
      mode = "console";
      level = "warn";
    };
    settings."log.console".format = "json";
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = 8030;
      enable_gzip = true;
      inherit domain;
    };
    settings.security = {
      admin_user = "admin";
      admin_password = "\$__file{${config.sops.secrets.grafana_admin_password.path}}";
      secret_key = "\$__file{${config.sops.secrets.grafana_secret_key.path}}";
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 8035;
        log_level = "warn";
        log_format = "json";
      };
      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = config.services.loki.dataDir;
      };
      schema_config.configs = [{
        from = "2024-05-14";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];
      storage_config.filesystem.directory = "${config.services.loki.dataDir}/chunks";
    };
  };

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      {
        job_name = "localhost";
        static_configs = [{
          targets = [
            config.services.vector.settings.sinks.prom.address
          ];
        }];
      }
      {
        job_name = "blueboi";
        static_configs = [{
          targets = [
            "192.168.14.12:9273"
          ];
        }];
      }
    ];
  };

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
          endpoint = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
          batch.timeout_secs = 10;
          encoding.codec = "logfmt";
        };
        prom = {
          type = "prometheus_exporter";
          inputs = [ "host_local" ];
          address = "127.0.0.1:9100";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port
    config.services.loki.configuration.server.http_listen_port
    config.services.prometheus.port
  ];

}
