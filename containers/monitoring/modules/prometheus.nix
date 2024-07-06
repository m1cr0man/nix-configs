{ config, ... }:
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "localhost";
      static_configs = [{
        targets = [
          "containerhost.local:${builtins.toString config.m1cr0man.monitoring.ports.vector_prom}"
        ];
      }];
    }
  ];
}
