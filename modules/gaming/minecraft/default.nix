{ pkgs, lib, config, ... }:
with lib;
let
  base = import ./service.nix { inherit pkgs lib; };
  cfg = filterAttrs (k: v: v.enable) config.m1cr0man.minecraft-servers;
  mcmonitor = pkgs.m1cr0man.mc-monitor;

  restartService = optionalAttrs (cfg != { }) {
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

  monitorService =
    let
      serverHosts = with builtins; concatStringsSep " " (mapAttrsToList
        (name: conf:
          "-servers 127.0.0.1:${toString conf.port}"
        )
        cfg);
    in
    optionalAttrs (cfg != { } && config.services.telegraf.enable) {
      minecraft-server-monitor = {
        description = "Monitor minecraft servers, report to Telegraf";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        script = "${mcmonitor}/bin/mc-monitor gather-for-telegraf -telegraf-address 127.0.0.1:8094 ${serverHosts}";
      };
    };
in
{
  imports = [
    ./options.nix
  ];

  networking.firewall.allowedTCPPorts = flatten (mapAttrsToList
    (name: conf: [
      conf.port
      (conf.port + 1)
    ])
    cfg);

  systemd.services = (mapAttrs'
    (name: conf: nameValuePair ("minecraft-${name}") (
      base.minecraftService {
        inherit (conf) name memGb jar jre user group ramfsDirectory stateDirectory launchCommand;
        secretsFile = config.sops.secrets.minecraft_rcon_env.path;
        serverProperties = conf.serverProperties // {
          "rcon.port" = conf.port + 1;
          "query.port" = conf.port;
          server-port = conf.port;
        };
      }
    ))
    cfg) // restartService // monitorService;

  sops.secrets.minecraft_rcon_env = { };

  users.users = mapAttrs'
    (name: conf: nameValuePair (conf.user) {
      isSystemUser = mkDefault true;
      group = conf.group;
    })
    cfg;
  users.groups = mapAttrs' (name: conf: nameValuePair (conf.group) { }) cfg;

  security.polkit.extraConfig = concatStringsSep "\n" (mapAttrsToList
    (name: conf: lib.m1cr0man.polkit.makeUnitRule {
      group = conf.group;
      unit = "minecraft-${name}.service";
    })
    cfg);

  systemd.timers = optionalAttrs (cfg != { }) {
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
}
