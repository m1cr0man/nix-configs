{ pkgs, ... }:
let
  latestJar = builtins.fetchurl {
    url = "https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar";
    sha256 = "0lrzpqd6zjvqh9g2byicgh66n43z0hwzp863r22ifx2hll6s2955";
  };
  latestJarPaper = builtins.fetchurl {
    url = "https://api.purpurmc.org/v2/purpur/1.19.4/1976/download";
    sha256 = "0lxzvgn4r6q02klsrxz07xx458k8wwkgdycnmwpdj6hfwi2bv1vr";
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
      memGb = 16;
      jar = "cf_MedievalMinecraftFABRIC_1.19.2_21HF.jar";
      user = "mcadmins";
      group = "mcadmins";
      port = 25525;
      serverProperties = {
        allow-flight = true;
        announce-player-achievements = true;
        broadcast-rcon-to-ops = true;
        difficulty = "easy";
        enable-command-block = false;
        enable-jmx-monitoring = false;
        enable-status = true;
        enforce-secure-profile = true;
        level-type = "bclib\\:normal";
        level-name = "Grand Land of Ampersand";
        max-chained-neighbor-updates = "1000000";
        max-players = "20";
        max-tick-time = "60000";
        max-world-size = "200000";
        motd = "CodexCon2023 - EYE Of THE COOKIE";
        rate-limit = "0";
        simulation-distance = "7";
        spawn-monsters = true;
        spawn-npcs = true;
        spawn-protection = "0";
        view-distance = "7";
        white-list = true;
      };
    };
  };
}
