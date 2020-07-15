let
  serverURL = "mcmodded.cragglerock.cf";
  secrets = import ../common/secrets.nix;
in {

  # Homepage and Dynmap setup
  security.acme.certs."m1cr0man.com".extraDomainNames = [ "${serverURL}" "dynmap.${serverURL}" ];

  services.httpd.virtualHosts."${serverURL}" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    documentRoot = "/var/gaming/mcmodded/www";
  };
  services.httpd.virtualHosts."dynmap.${serverURL}" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:8124/";
  };

  containers.mcmodded = {
    autoStart = true;
    bindMounts."/mcmodded" = {
      hostPath = "/var/gaming/mcmodded";
      isReadOnly = false;
      mountPoint = "/mcmodded";
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
            url = "https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.12.2-14.23.5.2847/forge-1.12.2-14.23.5.2847-universal.jar";
            sha256 = "0skapi02lp1ddy6i866d1dvis4vd4lwb5a7zmh0ymhh1b0mkg9r9";
          };
          installPhase = ''
            mkdir -p $out/bin $out/lib/minecraft
            cp -v $src $out/lib/minecraft/server.jar
            cat > $out/bin/minecraft-server << EOF
            #!/bin/sh
            exec ${pkgs.openjdk}/bin/java \$@ -jar forge-1.12.2-14.23.5.2847-universal.jar nogui
            EOF
            chmod +x $out/bin/minecraft-server
          '';
        });

        dataDir = "/mcmodded";

        declarative = false;

        jvmOpts = "-server -Xmx12G -Xms12G -XX:+UseConcMarkSweepGC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -Dfml.queryResult=confirm";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25565 25566 ];
}
