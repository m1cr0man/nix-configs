{ config, ... }:
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "localhost";
      static_configs = [{
        targets = [
          config.services.vector.settings.sinks.prom.address
          "192.168.14.12:9273"
        ];
      }];
    }
  ];
}
