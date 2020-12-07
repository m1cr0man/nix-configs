let
  secrets = import ../common/secrets.nix;
  hostPath = "/var/gaming/minecraft/creativity";
in {

  containers.mccreativity = {
    autoStart = true;
    bindMounts."/mccreativity" = {
      inherit hostPath;
      isReadOnly = false;
      mountPoint = "/mccreativity";
    };
  };

  containers.mccreativity.config =
    { config, pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      systemd.services.minecraft-server.serviceConfig.CPUShares = 768;
      systemd.services.minecraft-server.serviceConfig.MemoryLimit = "10G";
      services.minecraft-server = {

        enable = true;
        eula = true;

        package = pkgs.writeShellScriptBin "minecraft-server" ''
          exec ${pkgs.jre8}/bin/java -jar forge-1.15.2-31.2.45.jar nogui
        '';

        dataDir = "/mccreativity";

        declarative = true;

        serverProperties = {
          motd = "Creativity 1.15.2.2";
          enable-rcon = true;
          allow-flight = true;
          enable-query = true;
          level-seed = "-821503530";
          view-distance = 20;
          difficulty = "hard";
          "rcon.password" = secrets.minecraft_rcon_password;
          "rcon.port" = 25566;
        };

        jvmOpts = "-server -Xmx8G -Xms8G -XX:+UseConcMarkSweepGC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=50 -Dfml.queryResult=confirm";

        openFirewall = true;
      };
    };
  networking.firewall.allowedTCPPorts = [ 25565 25566 ];
}
