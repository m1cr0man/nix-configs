let
  secrets = import ../common/secrets.nix;
in {
  containers.mcadam = {
    autoStart = true;
    bindMounts."/mcadam" = {
      hostPath = "/var/gaming/minecraft/adam";
      isReadOnly = false;
      mountPoint = "/mcadam";
    };
  };

  containers.mcadam.config =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      systemd.services.minecraft-server.serviceConfig.CPUShares = 256;
      systemd.services.minecraft-server.serviceConfig.MemoryLimit = "3328M";

      systemd.services.minecraft-server-restart = {
        description = "Restart minecraft server";
        requisite = [ "minecraft-server.service" ];
        serviceConfig = {
          Type = "oneshot";
          SuccessExitStatus = [ "0" "1" ];
          PermissionsStartOnly = true;
        };
        script = "systemctl restart minecraft-server";
      };

      systemd.timers.minecraft-server-restart = {
        requisite = [ "minecraft-server.service" ];
        description = "Restart minecraft server at 5AM every day";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 05:00:00";
          Unit = "minecraft-server-restart.service";
          Persistent = "yes";
          AccuracySec = "5m";
        };
      };

      services.minecraft-server = {

        enable = true;
        eula = true;

        package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
          name = "minecraft-server-1.15.2.paper";
          version = "1.15.2.paper";
          src = pkgs.fetchurl {
            url = "https://papermc.io/api/v1/paper/1.15.2/335/download";
            sha256 = "1g74b7l3nhrx5yb5hr255h8jz2b868rr252lx6kisd9rgkjrg6n2";
          };
        });

        dataDir = "/mcadam";

        declarative = true;

        serverProperties = {
          server-port = 25545;
          motd = "Flooby Tooty";
          enable-rcon = true;
          "rcon.port" = 25546;
          "query.port" = 25545;
          "rcon.password" = secrets.minecraft_rcon_password;
        };

        jvmOpts = "-server -Xmx3G -Xms3G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25545 25546 ];
}
