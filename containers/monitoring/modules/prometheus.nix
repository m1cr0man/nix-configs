{ config, ... }:
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "localhost";
      static_configs = [{
        targets = [
          "containerhost.local:${config.m1cr0man.monitoring.ports.vector_prom}"
        ];
      }];
    }
  ];
}
