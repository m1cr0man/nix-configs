{ pkg, config, lib, domain, ... }:
{
  sops.secrets.grafana_admin_password.owner = config.systemd.services.grafana.serviceConfig.User;
  sops.secrets.grafana_secret_key.owner = config.systemd.services.grafana.serviceConfig.User;

  systemd.services.grafana.serviceConfig.StateDirectory = "grafana";

  services.grafana = {
    enable = true;
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
      server.http_listen_port = 8035;
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
            "localhost:${toString config.services.prometheus.exporters.node.port}"
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

    exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
      disabledCollectors = [
        "textfile"
      ];
    };
  };


  services.promtail = {
    enable = true;
    configuration = {
      server.disable = true;
      positions.filename = "/var/cache/promtail/positions.yaml";
      scrape_configs = [{
        job_name = "journald";
        journal = {
          max_age = "1h";
          labels.source = "journald";
        };
      }];
      clients = [{
        url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        batchwait = "10s";
      }];
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port
    config.services.loki.configuration.server.http_listen_port
    config.services.prometheus.port
  ];

}
