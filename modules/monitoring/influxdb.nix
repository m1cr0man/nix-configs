{ config, lib, ... }:
let
  cfg = config.m1cr0man.influxdb;

  bindAddress = cfg.bindAddress;
in
{
  options.m1cr0man.influxdb = with lib; {
    bindAddress = mkOption {
      default = "127.0.0.1";
      type = types.str;
      description = "What address to run influxdb on. Covers multiple endpoints/ports.";
    };
  };

  config = {
    services.influxdb = {
      enable = true;
      dataDir = "/var/lib/tick/influxdb";
      extraConfig = {
        admin.enabled = false;
        data.query-log-enabled = false;
        http = {
          bind-address = "${bindAddress}:8086";
          log-enabled = false;
        };
        udp = [{
          enabled = true;
          bind-address = "${bindAddress}:8089";
          database = "telegraf";
          retention-policy = "14d";
        }];
        # Upstream sets typesdb to a value depending on collectd.
        # Collectd depends on xen, which is deprecated, and thus
        # fails the config eval.
        collectd = [{
          enabled = false;
          typesdb = "";
        }];
      };
    };
  };
}
