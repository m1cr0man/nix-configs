{ pkgs, config, ... }:
{
  users.users.minecraft = {
    isSystemUser = true;
    createHome = false;
    home = "/var/empty";
    group = "minecraft";
  };
  users.groups.minecraft = {};

  m1cr0man.minecraft-servers.mekcreate = {
    enable = true;
    launchCommand = "java -Xmx10G -Xms5G @libraries/net/minecraftforge/forge/1.19.2-43.2.6/unix_args.txt";
    # These 2 args won't actually be used
    memGb = 10;
    jar = "forge-1.19.2-43.2.6-server.jar";
    port = 25565;
    user = "minecraft";
    group = "minecraft";
    serverProperties = {
      difficulty = "normal";
      enable-command-block = true;
      enable-jmx-monitoring = false;
      enable-status = true;
      level-type = "minecraft:normal";
      level-seed = "ineedthelooagain";
      max-players = "15";
      max-tick-time = "90000";
      max-world-size = "200000";
      motd = "Create Mekanized 1.19";
      simulation-distance = "10";
      spawn-protection = "0";
      view-distance = "10";
    };
  };
}
