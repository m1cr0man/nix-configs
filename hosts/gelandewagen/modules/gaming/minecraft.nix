{ pkgs, ... }:
let
  latestJar = builtins.fetchurl {
    url = "https://launcher.mojang.com/v1/objects/3cf24a8694aca6267883b17d934efacc5e44440d/server.jar";
    sha256 = "0vvycjcfq96z7cl5dsrq98k9b7j7l4x0y9nflrcqmcvink7fs5w4";
  };
  latestJarPaper = builtins.fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/1.18.1/builds/101/downloads/paper-1.18.1-101.jar";
    sha256 = "0a8bg9f0vg6507a6aj7ag5788vrd0jxp6iq9nldddfk7h8p3bxp7";
  };
in
{
  m1cr0man.minecraft-servers = {
    create = {
      enable = true;
      memGb = 10;
      zramSizeGb = 5;
      zramDevice = "/dev/zram1";
      jar = "forge-1.16.5-36.2.20.jar";
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

    cpssd = {
      enable = true;
      memGb = 6;
      zramSizeGb = 5;
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
      enable = true;
      memGb = 4;
      jar = latestJarPaper;
      user = "mcadmins";
      group = "mcadmins";
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
