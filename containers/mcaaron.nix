let
  secrets = import ../common/secrets.nix;
in {
  containers.mcaaron = {
    autoStart = true;
    bindMounts."/mcaaron" = {
      hostPath = "/var/gaming/minecraft/aaron";
      isReadOnly = false;
      mountPoint = "/mcaaron";
    };
  };

  containers.mcaaron.config =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      systemd.services.minecraft-server.serviceConfig.CPUShares = 256;
      systemd.services.minecraft-server.serviceConfig.MemoryLimit = "5120M";

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
          name = "minecraft-server-1.16.3";
          version = "1.16.3";
          src = pkgs.fetchurl {
            url = "https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar";
            sha256 = "0nxdyw23037cr9cfcsfq1cvpy75am5dzmbgvvh3fq6h89kkm1r1j";
          };
        });

        dataDir = "/mcaaron";

        declarative = true;

        serverProperties = {
          server-port = 25535;
          motd = "MC PSSD";
          enable-rcon = true;
          "rcon.port" = 25536;
          "query.port" = 25535;
          "rcon.password" = secrets.minecraft_rcon_password;
        };

        jvmOpts = "-server -Xmx4G -Xms4G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25535 25536 ];
}
