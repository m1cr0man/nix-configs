let
  secrets = import ../common/secrets.nix;
in {
  containers.mcadam = {
    autoStart = true;
    bindMounts."/adam_mc" = {
      hostPath = "/zstorage/adam_mc";
      isReadOnly = false;
      mountPoint = "/adam_mc";
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
          name = "minecraft-server-1.14.3.spigot";
          version = "1.14.3.spigot";
          src = pkgs.fetchurl {
            url = "https://cdn.getbukkit.org/spigot/spigot-1.14.3.jar";
            sha256 = "06xlkxswvcwjjai3zz0lbyla51zj98jfk8whixamglgr449y52ii";
          };
        });

        dataDir = "/adam_mc";

        declarative = true;

        serverProperties = {
          server-port = 25535;
          motd = "Flubnuts mc";
          enable-rcon = true;
          "rcon.port" = 25536;
          "rcon.password" = secrets.minecraft_rcon_password;
        };

        jvmOpts = "-server -Xmx4G -Xms4G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25535 25536 ];
}
