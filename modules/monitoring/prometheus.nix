{ config, ... }:
{
  services.prometheus = {
    enable = true;
    extraFlags = [
      "--web.enable-remote-write-receiver"
    ];
    # Very little to do here. scrapeConfigs should be handled per-deployment
  };
}
