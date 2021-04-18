{ config, ... }:
let
  bindAddress = config.m1cr0man.influxdb.bindAddress;
in {
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
    };
  };
}
