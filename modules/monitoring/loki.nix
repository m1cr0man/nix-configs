{ config, ... }:
let
  ports = config.m1cr0man.monitoring.ports;
in
{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = ports.loki;
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
      limits_config = {
        retention_period = "48h";
      };
      compactor = {
        working_directory = "${config.services.loki.dataDir}/retention";
        compaction_interval = "1h";
        retention_enabled = true;
        retention_delete_delay = "2h";
        retention_delete_worker_count = 4;
        delete_request_store = "filesystem";
      };
    };
  };
}
