# Mostly a clone of the nixpkgs minecraft role to support
# multiple servers.
{ pkgs, lib }:
let
  secrets = import ../../common/secrets.nix;

  mcRoot = /var/gaming/minecraft;
  commonArgs = "-server"
    + " -XX:ParallelGCThreads=2 -XX:MaxGCPauseMillis=50"
    + " -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"
    + " -XX:SurvivorRatio=5 -XX:TargetSurvivorRatio=90"
    + " -Dfml.queryResult=confirm -Dpaper.playerconnection.keepalive=300";

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  commonProps = {
    enable-rcon = true;
    allow-flight = true;
    enable-query = true;
    view-distance = 20;
    "rcon.password" = secrets.minecraft_rcon_password;
  };

  serverPropertiesFile = props: with lib; pkgs.writeText "server.properties" (''
    # server.properties managed by NixOS configuration
  '' + concatStringsSep "\n" (mapAttrsToList
    (n: v: "${n}=${cfgToString v}") (commonProps // props)));
in {
  minecraftService = {name, memGb, jar, serverProperties, user, group, jre}: let
    serverRoot = mcRoot + "/${name}";
    memStr = "${builtins.toString memGb}G";
    memHalfStr = "${builtins.toString (memGb / 2)}G";
    propsFile = serverPropertiesFile serverProperties;
  in {
    description = serverProperties.motd;
    aliases = [ "mc-${name}" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;

    preStart = ''
      echo eula=true > eula.txt
      cp -b --suffix=.stateful ${propsFile} server.properties
    '';

    serviceConfig = {
      MemoryMax = "${builtins.toString (memGb + 2)}G";
      CPUWeight = 40;
      Restart = "always";
      RestartSec = 10;
      User = user;
      Group = group;
      UMask = 0002;
      WorkingDirectory = serverRoot;
      PrivateTmp = true;
      ExecStart = "${jre}/bin/java -Xmx${memStr} -Xms${memHalfStr} ${commonArgs} -jar ${jar} nogui";
    };
  };
}
