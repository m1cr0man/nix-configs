{ pkgs, lib, config, ... }:
with lib;
let
  base = import ./service.nix { inherit pkgs lib; };
  secrets = import ../../common/secrets.nix;
  cfg = config.m1cr0man.minecraft-servers;

  restartService = optionalAttrs (cfg != {}) {
    minecraft-server-restart = {
      description = "Restart minecraft server";
      serviceConfig = {
        Type = "oneshot";
        SuccessExitStatus = [ "0" "1" ];
        PermissionsStartOnly = true;
      };
      script = builtins.concatStringsSep "\nsleep 30\n" (
        mapAttrsToList (name: conf: "systemctl restart minecraft-${name}") cfg
      );
    };
  };
in {
  imports = [
    ./options.nix
  ];

  networking.firewall.allowedTCPPorts = flatten (mapAttrsToList (name: conf: [
    conf.port (conf.port + 1)
  ]) cfg);

  services.telegraf.inputs.minecraft = (mapAttrsToList (name: conf: {
    server = "127.0.0.1";
    port = conf.port;
    password = secrets.minecraft_rcon_password;
  }));

  systemd.services = (mapAttrs' (name: conf: nameValuePair ("minecraft-${name}") (
    base.minecraftService {
      name = conf.name;
      memGb = conf.memGb;
      jar = conf.jar;
      serverProperties = conf.serverProperties // {
        "rcon.port" = conf.port + 1;
        "query.port" = conf.port;
        server-port = conf.port;
      };
    }
  )) cfg) // restartService;

  systemd.timers = optionalAttrs (cfg != {}) {
    minecraft-server-restart = {
      description = "Restart minecraft servers at 5AM every day";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
        Unit = "minecraft-server-restart.service";
        Persistent = "yes";
        AccuracySec = "5m";
      };
    };
  };

  users.users.minecraft = {
    description = "Minecraft server service user";
    home = "/var/empty";
    uid = config.ids.uids.minecraft;
  };
}
