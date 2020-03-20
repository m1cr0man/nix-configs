let
  secrets = import ../common/secrets.nix;
in {
  containers.mcadam = {
    autoStart = true;
    bindMounts."/mcadam" = {
      hostPath = "/var/gaming/mcadam";
      isReadOnly = false;
      mountPoint = "/mcadam";
    };
  };

  containers.mcadam.config =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      systemd.services.minecraft-server.serviceConfig.CPUShares = 256;
      systemd.services.minecraft-server.serviceConfig.MemoryLimit = "5G";
      services.minecraft-server = {

        enable = true;
        eula = true;

        package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
          name = "minecraft-server-1.15.2.paper";
          version = "1.15.2.paper";
          src = pkgs.fetchurl {
            url = "https://papermc.io/api/v1/paper/1.15.2/142/download";
            sha256 = "18mb54fc0630fk9ndbsjs8w4hxdb9xp42nf01n2qb0yc5n3y1vyd";
          };
        });

        dataDir = "/mcadam";

        declarative = true;

        serverProperties = {
          server-port = 25545;
          motd = "Flooby Tooty";
          enable-rcon = true;
          "rcon.port" = 25546;
          "rcon.password" = secrets.minecraft_rcon_password;
        };

        jvmOpts = "-server -Xmx4G -Xms4G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25545 25546 ];
}
