{ config, ... }:
{
  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    port = 8030;
    domain = config.networking.hostName;
    dataDir = "/var/lib/grafana";
    security = {
      adminUser = "m1cr0man";
      adminPasswordFile = "/var/secrets/grafana_admin.txt";
      secretKey = "/var/secrets/grafana_secret_key.txt";
    };
    provision.enable = true;
    provision.datasources = [{
      name = "InfluxDB";
      type = "influxdb";
      access = "proxy";
      database = "telegraf";
      url = "http://localhost:8086";
    }];
  };
}
