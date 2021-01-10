{ pkgs, ... }:
let
  latestJar = pkgs.fetchurl {
    url = "https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar";
    sha256 = "01i5nd03sbnffbyni1fa6hsg5yll2h19vfrpcydlivx10gck0ka4";
  };
in {
  imports = [ ../../services/minecraft ];

  m1cr0man.minecraft-servers = {
    creativity = {
      memGb = 8;
      jar = "forge-1.15.2-31.2.45.jar";
      port = 25555;
      serverProperties = {
        motd = "Creativity 1.15.2.4";
        level-seed = "-821503530";
        difficulty = "hard";
      };
    };

    cpssd = {
      memGb = 8;
      jar = latestJar;
      port = 25535;
      serverProperties = {
        motd = "MC PSSD";
        enable-command-block = true;
      };
    };

    # patrick = {
    #   memGb = 2;
    #   jar = latestJar;
    #   port = 25545;
    #   serverProperties = {
    #     motd = "Idk Patrick's brother";
    #   };
    # };

    adam = {
      memGb = 4;
      jar = latestJar;
      port = 25525;
      serverProperties = {
        motd = "The big Savva House";
      };
    };
  };
}
