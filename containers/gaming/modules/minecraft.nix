{ pkgs, ... }:
let
  latestJar = builtins.fetchurl {
    url = "https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar";
    sha256 = "06qykz3nq7qmfw4phs3wvq3nk28clg8s3qrs37856aai8b8kmgaf";
  };
  latestJarPaper = builtins.fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/1.18.2/builds/268/downloads/paper-1.18.2-268.jar";
    sha256 = "sha256:1hn4dcz9bhpdg5h0cw2jy97ai88qy485z2pny1v04z665lvqj0qh";
  };
in
{
  m1cr0man.minecraft-servers = {
    vaulthunters = {
      enable = true;
      ramfsDirectory = "/var/lib/gaming/zram1";
      launchCommand = "java -Xmx10G -Xms5G @libraries/net/minecraftforge/forge/1.18.2-40.1.93/unix_args.txt";
      # These 2 args won't actually be used
      memGb = 10;
      jar = "forge-1.18.2-40.1.93.jar";
      port = 25555;
      user = "mcadmins";
      group = "mcadmins";
      serverProperties = {
        difficulty = "normal";
        enable-command-block = true;
        enable-jmx-monitoring = false;
        enable-status = true;
        level-type = "default";
        max-players = "15";
        max-tick-time = "90000";
        max-world-size = "200000";
        motd = "Vault Hunters 1.18";
        simulation-distance = "10";
        spawn-protection = "0";
        view-distance = "10";
      };
    };

    focreate = {
      enable = false;
      memGb = 6;
      ramfsDirectory = "/var/lib/gaming/zram0";
      jar = "fabric-server-launch.jar";
      port = 25535;
      user = "mcadmins";
      group = "mcadmins";
      serverProperties = {
        motd = "Fabulously Optimised Create 1.18.2";
        max-world-size = "29999984";
        max-players = "15";
        max-tick-time = "90000";
        view-distance = "15";
        difficulty = "hard";
        prevent-proxy-connections = false;
      };
    };

    adam = {
      enable = false;
      memGb = 4;
      jar = latestJar;
      user = "mcadmins";
      group = "mcadmins";
      port = 25525;
      serverProperties = {
        motd = "The Big Savva House";
        white-list = true;
      };
    };
  };
}
