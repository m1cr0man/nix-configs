{ pkgs, ... }:
let
  latestJar = pkgs.fetchurl {
    url = "https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar";
    sha256 = "19ix6x5ij4jcwqam1dscnqwm0m251gysc2j793wjcrb9sb3jkwsq";
  };
  latestJarPaper = pkgs.fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/574/downloads/paper-1.16.5-574.jar";
    sha256 = "0g8h03wsnlx2lhm84q8cyzvg11a68i3qkf46ck9ra84i9xzf9grf";
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
      jar = latestJarPaper;
      port = 25525;
      serverProperties = {
        motd = "The big Savva House";
      };
    };
  };
}
