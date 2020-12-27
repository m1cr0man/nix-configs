{ pkgs, ... }:
let
  latestJar = pkgs.fetchurl {
    url = "https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar";
    sha256 = "0nxdyw23037cr9cfcsfq1cvpy75am5dzmbgvvh3fq6h89kkm1r1j";
  };
in {
  imports = [ ../../services/minecraft ];

  m1cr0man.minecraft-servers = {
    creativity = {
      memGb = 8;
      jar = "forge-1.15.2-31.2.45.jar";
      port = 25555;
      serverProperties = {
        motd = "Creativity 1.15.2.2";
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

    patrick = {
      memGb = 2;
      jar = latestJar;
      port = 25545;
      serverProperties = {
        motd = "Idk Patrick's brother";
      };
    };
  };
}
