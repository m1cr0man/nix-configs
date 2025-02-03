{ pkgs, lib, config, ... }: {
  services.mainsail = {
    enable = true;
    nginx.default = true;
    hostName = config.networking.hostName;
  };

  networking.firewall.allowedTCPPorts = [
    80 443
  ];
}
