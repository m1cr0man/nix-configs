{ pkgs, ... }:

{
  m1cr0man.minecraft-servers = {
    technae = {
      enable = true;
      launchCommand = "java -Xmx16G -Xms5G @libraries/net/minecraftforge/forge/1.19.2-43.2.14/unix_args.txt";
      # These two arguments won't actually be used
      memGb = 16;
      jar = "forge-1.19.2-43.2.14.jar";
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
        level-type = "minecraft\\:normal";
        level-name = "Our Reality";
        max-chained-neighbor-updates = "1000000";
        max-players = "20";
        max-tick-time = "60000";
        max-world-size = "200000";
        motd = "WOW COOL SESRVER";
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
