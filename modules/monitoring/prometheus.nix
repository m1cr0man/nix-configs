{ config, ... }:
{
  services.prometheus = {
    enable = true;
    extraFlags = [
      "--web.enable-remote-write-receiver"
    ];
    retentionTime = "90d";
    # Very little to do here. scrapeConfigs should be handled per-deployment
  };
}
