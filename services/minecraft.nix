{ pkgs, ... }:
let
  serverURL = "rhicord.cragglerock.cf";
in {
  nixpkgs.config.allowUnfree = true;
  systemd.services.minecraft-server.serviceConfig.CPUShares = 256;
  systemd.services.minecraft-server.serviceConfig.MemoryLimit = "5G";
  services.minecraft-server = {
    enable = true;
    eula = true;

    package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
      name = "minecraft-server-1.14.4.paper";
      version = "1.14.4.paper";
      src = pkgs.fetchurl {
        url = "https://papermc.io/api/v1/paper/1.14.4/171/download";
        sha256 = "12v1nwb2q2kq5856agngx48ry8f8vv4aym8bsapsvks0dzv8vs21";
      };
    });

    dataDir = "/zroot/rhiannon_mc";

    declarative = false;

    jvmOpts = "-server -Xmx4G -Xms4G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

    openFirewall = false;
  };

  # Dynmap setup
  security.acme.certs."m1cr0man.com".extraDomains."${serverURL}" = null;
  security.acme.certs."m1cr0man.com".extraDomains."dynmap.${serverURL}" = null;
  services.httpd.virtualHosts."${serverURL}" = {
    onlySSL = true;
    useACMEHost = "m1cr0man.com";
    serverAliases = [ "dynmap.${serverURL}" ];
    extraConfig = "ProxyPass / http://127.0.0.1:8123/";
  };

  networking.firewall.allowedTCPPorts = [ 25585 25595 ];
}
