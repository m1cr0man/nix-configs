{
  services.influxdb = {
    enable = true;
    dataDir = "/zroot/tick/influxdb";
    extraConfig = {
      admin.enabled = false;
      data.query-log-enabled = false;
      http = {
        bind-address = "127.0.0.1:8086";
        log-enabled = false;
      };
      udp = [{
        enabled = true;
        bind-address = "127.0.0.1:8089";
        database = "telegraf";
        retention-policy = "14d";
      }];
    };
  };
}
