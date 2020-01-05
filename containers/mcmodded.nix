let
  serverURL = "mcmodded.cragglerock.cf";
  secrets = import ../common/secrets.nix;
in {

  # Homepage and Dynmap setup
  security.acme.certs."m1cr0man.com".extraDomains."${serverURL}" = null;
  security.acme.certs."m1cr0man.com".extraDomains."dynmap.${serverURL}" = null;

  services.httpd.virtualHosts."${serverURL}" = {
    onlySSL = true;
    useACMEHost = "m1cr0man.com";
    documentRoot = "/zroot/modded_mc/www";
  };
  services.httpd.virtualHosts."dynmap.${serverURL}" = {
    onlySSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:8124/";
  };

  containers.mcmodded = {
    autoStart = true;
    bindMounts."/modded_mc" = {
      hostPath = "/zroot/modded_mc";
      isReadOnly = false;
      mountPoint = "/modded_mc";
    };
  };

  containers.mcmodded.config =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      systemd.services.minecraft-server.serviceConfig.CPUShares = 768;
      systemd.services.minecraft-server.serviceConfig.MemoryLimit = "14G";
      services.minecraft-server = {

        enable = true;
        eula = true;

        # TODO clean up this mess. Probably don't even need a container if I write a custom service
        package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
          name = "minecraft-server-1.12.2.forge";
          version = "1.12.2.forge";
          src = pkgs.fetchurl {
            url = "https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.12.2-14.23.5.2838/forge-1.12.2-14.23.5.2838-universal.jar";
            sha256 = "02r4ikx4cca5wlcm386llfr05n20sg2z0fs8kyijh25ipqjsik37";
          };
          installPhase = ''
            mkdir -p $out/bin $out/lib/minecraft
            cp -v $src $out/lib/minecraft/server.jar
            cat > $out/bin/minecraft-server << EOF
            #!/bin/sh
            exec ${pkgs.openjdk}/bin/java \$@ -jar forge-1.12.2-14.23.5.2838-universal.jar nogui
            EOF
            chmod +x $out/bin/minecraft-server
          '';
        });

        dataDir = "/modded_mc";

        declarative = false;

        jvmOpts = "-server -Xmx12G -Xms12G -XX:+UseConcMarkSweepGC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -Dfml.queryResult=confirm";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25565 25566 ];
}
