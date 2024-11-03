{ config, ... }:
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "localhost";
      static_configs = [{
        targets = [
          "192.168.14.12:9273"
        ];
      }];
    }
  ];
}
