{ pkgs, ... }:
let
  serverURL = "mcvanilla.cragglerock.cf";
in {
  nixpkgs.config.allowUnfree = true;
  services.minecraft-server = {
    enable = true;
    eula = true;

    package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
      name = "minecraft-server-1.14.2.spigot";
      version = "1.14.2.spigot";
      src = import ./spigot.nix;
    });

    dataDir = "/zstorage/craig_mc";

    declarative = false;

    jvmOpts = "-server -Xmx8G -Xms8G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

    openFirewall = false;
  };

  # Dynmap setup
  security.acme.certs."m1cr0man.com".extraDomains."dynmap.${serverURL}" = null;
  services.httpd.virtualHosts = [{
    enableSSL = true;
    hostName = "dynmap.${serverURL}";
    extraConfig = "ProxyPass / http://127.0.0.1:8123/";
  }];
}
