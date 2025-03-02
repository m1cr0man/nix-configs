{ pkgs, lib, config, ... }: {
  services.mainsail = {
    enable = true;
    nginx.default = true;
    hostName = config.networking.hostName;
  };

  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    settings = {
      file_manager.enable_object_processing = true;
      octoprint_compat = { };
      history = { };
      authorization = {
        force_logins = true;
        cors_domains = [
          "*.m1cr0man.com"
          "*://enderpi"
          "*://enderpi.lucas.ts.m1cr0man.com"
        ];
        trusted_clients = [
          "100.64.0.0/16"
          "192.168.0.0/16"
          "127.0.0.1/32"
          "fd7a::/16"
        ];
      };
    };
  };

  users = {
    groups.klipper = {};
    users.klipper = {
      group = "klipper";
      isSystemUser = true;
      home = "/var/lib/klipper";
    };
    users.moonraker.extraGroups = [ "klipper" ];
  };

  services.klipper = rec {
    enable = true;
    user = "klipper";
    group = "klipper";
  };

  networking.firewall.allowedTCPPorts = [
    80 443
  ];
}
