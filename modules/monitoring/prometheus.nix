{ config, ... }:
{
  services.prometheus = {
    enable = true;

    # Very little to do here. scrapeConfigs should be handled per-deployment
  };
}
