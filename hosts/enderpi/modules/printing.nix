{ pkgs, lib, config, ... }: let
  mainsail_config = pkgs.fetchFromGitHub {
    owner = "mainsail-crew";
    repo = "mainsail-config";
    rev = "ff3869a621db17ce3ef660adbbd3fa321995ac42";
    hash = "sha256-gDMAUDqf8no66Jc/jutFNwu7RbD+/qD/6Q6GLWOAA/k=";
  };
  username = "moonraker";
  dataDir = "/var/lib/moonraker";
  hostName = config.networking.hostName;
in {
  # The web interface
  services.mainsail = {
    enable = true;
    nginx.default = true;
    inherit hostName;
  };

  # The REST API for klipper
  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    user = username;
    group = username;
    settings = {
      file_manager.enable_object_processing = true;
      octoprint_compat = { };
      history = { };
      authorization = {
        force_logins = true;
        cors_domains = [
          "*.m1cr0man.com"
          "*://${hostName}"
          "*://${hostName}.lucas.ts.m1cr0man.com"
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

  services.klipper = rec {
    enable = true;
    user = username;
    group = username;
    settings = {
      "include mainsail.cfg" = {};
      "virtual_sdcard".path = "${dataDir}/gcodes";
    };
  };

  # Configuration required to use klipper, mainsail and moonraker together
  systemd.services.klipper-mainsail-config = {
    description = "Downloads and installs mainsail-config";
    wantedBy = [ "klipper.service" ];
    before = [ "klipper.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = username;
      Group = username;
    };
    script = ''
      cp -f '${mainsail_config}/client.cfg' '${config.services.klipper.configDir}/mainsail.cfg'
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80 443 7125
  ];
}
