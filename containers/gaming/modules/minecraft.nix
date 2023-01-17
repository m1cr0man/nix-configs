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
    create = {
      enable = false;
      memGb = 10;
      ramfsDirectory = "/var/lib/gaming/zram1";
      jar = "forge-1.16.5-36.2.35.jar";
      jre = pkgs.jre8;
      port = 25555;
      user = "mcadmins";
      group = "mcadmins";
      serverProperties = {
        motd = "Create 1.3 mc 1.16";
        level-type = "biomesoplenty";
        max-world-size = "200000";
        max-players = "15";
        max-tick-time = "90000";
        view-distance = "8";
        difficulty = "normal";
      };
    };

    focreate = {
      enable = true;
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

    patrick = {
      enable = false;
      memGb = 2;
      jar = latestJar;
      port = 25545;
      serverProperties = {
        motd = "Idk Patrick's brother";
      };
    };

    adam = {
      enable = true;
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

    test = {
      enable = false;
      memGb = 6;
      jar = "fabric-server-launch.jar";
      port = 25515;
      user = "mcadmins";
      group = "mcadmins";
      serverProperties = {
        motd = "[QA] Fabulously Optimised Create 1.18.2";
        max-world-size = "29999984";
        max-players = "15";
        max-tick-time = "90000";
        view-distance = "15";
        difficulty = "hard";
        prevent-proxy-connections = false;
      };
    };
  };
}
