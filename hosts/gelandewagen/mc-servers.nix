{ pkgs, ... }:
let
  latestJar = pkgs.fetchurl {
    url = "https://launcher.mojang.com/v1/objects/3cf24a8694aca6267883b17d934efacc5e44440d/server.jar";
    sha256 = "0vvycjcfq96z7cl5dsrq98k9b7j7l4x0y9nflrcqmcvink7fs5w4";
  };
  latestJarPaper = pkgs.fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/1.17.1/builds/136/downloads/paper-1.17.1-136.jar";
    sha256 = "0y0vssg2jwggdkz812sm9i5xs3996sl014w6mb87b352b7ligwsv";
  };
in {
  imports = [ ../../services/minecraft ];

  m1cr0man.minecraft-servers = {
    creativity = {
      enable = false;
      memGb = 6;
      jar = "forge-1.15.2-31.2.45.jar";
      jre = pkgs.jre8;
      port = 25555;
      serverProperties = {
        motd = "Creativity 1.15.2.4";
        level-seed = "-821503530";
        difficulty = "hard";
      };
    };

    cpssd = {
      enable = true;
      memGb = 10;
      zramSizeGb = 6;
      zramDevice = "/dev/zram0";
      jar = "fabric-server-launch.jar";
      port = 25535;
      user = "mcadmins";
      group = "mcadmins";
      serverProperties = {
        motd = "MC PSSD";
        level-seed = "-2873225848197999158";
        max-world-size = "29999984";
        max-players = "15";
        max-tick-time = "30000";
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
      enable = false;
      memGb = 3;
      jar = latestJarPaper;
      port = 25525;
      serverProperties = {
        motd = "The big Savva House";
      };
    };

    test = {
      enable = false;
      memGb = 6;
      zramSizeGb = 4;
      zramDevice = "/dev/zram1";
      jar = "fabric-server-launch.jar";
      port = 25515;
      user = "mcadmins";
      group = "mcadmins";
      serverProperties = {
        motd = "[QA] MC PSSD";
        level-seed = "-7379792622640751045";
        max-world-size = "29999984";
        max-players = "15";
        max-tick-time = "30000";
        view-distance = "10";
        difficulty = "hard";
        prevent-proxy-connections = false;
      };
    };
  };
}
