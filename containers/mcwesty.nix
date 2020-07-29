let
  serverURL = "mcwesty.m1cr0man.com";
  gameRoot = "/var/gaming/minecraft/westy";
  containerName = "mcwesty";
in {

  # Homepage and Dynmap setup
  security.acme.certs."m1cr0man.com".extraDomainNames = [ serverURL "dynmap.${serverURL}" ];

  services.httpd.virtualHosts.${serverURL} = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    documentRoot = "${gameRoot}/www";
  };
  services.httpd.virtualHosts."dynmap.${serverURL}" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:8125/";
  };

  networking.firewall.allowedTCPPorts = [ 25575 25576 ];

  containers.${containerName} = {
    autoStart = true;
    bindMounts."/minecraft" = {
      hostPath = gameRoot;
      isReadOnly = false;
      mountPoint = "/minecraft";
    };
    config = { config, pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;
      systemd.services.minecraft-server.serviceConfig.CPUShares = 768;
      systemd.services.minecraft-server.serviceConfig.MemoryLimit = "14G";
      services.minecraft-server = {

        enable = true;
        eula = true;

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

        dataDir = "/minecraft";

        declarative = false;

        jvmOpts = "-server -Xmx12G -Xms12G -XX:+UseConcMarkSweepGC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -Dfml.queryResult=confirm";

        openFirewall = true;
      };
    };
  };
}
