{ pkgs, ... }:
let
  secrets = import ../common/secrets.nix;
  serverURL = "speedrun.m1cr0man.com";
  dataDir = "/var/gaming/minecraft/speedrun";
in {
  systemd.services.minecraft-server.serviceConfig.CPUShares = 256;
  systemd.services.minecraft-server.serviceConfig.MemoryLimit = "4G";
  systemd.services.minecraft-server.unitConfig.RequiresMountsFor = dataDir;

  services.minecraft-server = {
    inherit dataDir;

    enable = true;
    eula = true;

    package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
      name = "minecraft-server-1.14.4.paper";
      version = "1.14.4.paper";
      src = pkgs.fetchurl {
        url = "https://papermc.io/api/v1/paper/1.15.2/335/download";
        sha256 = "1g74b7l3nhrx5yb5hr255h8jz2b868rr252lx6kisd9rgkjrg6n2";
      };
    });

    declarative = true;

	serverProperties = {
      max-players = 8;
	  difficulty = "normal";
	  motd = "Manhunter challenge";
	  enable-rcon = true;
	  server-port = 25585;
	  "rcon.port" = 25586;
	  "query.port" = 25585;
	  "rcon.password" = secrets.minecraft_rcon_password;
	};

    jvmOpts = "-server -Xmx4G -Xms4G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

    openFirewall = false;
  };


  networking.firewall.allowedTCPPorts = [ 25585 25586 ];
}
