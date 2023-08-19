# Mostly a clone of the nixpkgs minecraft role to support
# multiple servers.
{ pkgs, lib }:
let
  log4jConf = ./log4j2.xml;

  commonArgs = "-server"
    + " -XX:ParallelGCThreads=2 -XX:MaxGCPauseMillis=50"
    + " -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10"
    + " -XX:SurvivorRatio=5 -XX:TargetSurvivorRatio=90"
    + " -Dfml.queryResult=confirm -Dpaper.playerconnection.keepalive=300"
    + " -Dlog4j2.formatMsgNoLookups=true -Dlog4j.configurationFile=${log4jConf}";

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  commonProps = {
    enable-rcon = true;
    allow-flight = true;
    enable-query = true;
    view-distance = 16;
    # Will be set by sed in preStartScript
    "rcon.password" = "RCON_PASSWORD_RUNTIME";
  };

  serverPropertiesFile = props: with lib; pkgs.writeText "server.properties" (''
    # server.properties managed by NixOS configuration
  '' + concatStringsSep "\n" (mapAttrsToList
    (n: v: "${n}=${cfgToString v}")
    (commonProps // props)));
in
{
  minecraftService = { name, memGb, jar, serverProperties, user, group, jre, ramfsDirectory, secretsFile, stateDirectory, launchCommand }:
    let
      memStr = "${builtins.toString memGb}G";
      memHalfStr = "${builtins.toString (memGb / 2)}G";
      propsFile = serverPropertiesFile serverProperties;
      mcrcon = "mcrcon -s -P ${builtins.toString serverProperties."rcon.port"} -p \"$RCON_PASSWORD\"";
      preStartScript = pkgs.writeShellScript "mc-${name}-prestart" (''
        set -euxo pipefail
        mkdir -p ${stateDirectory}
        cd ${stateDirectory}
        echo eula=true > eula.txt
        sed "s/RCON_PASSWORD_RUNTIME/''${RCON_PASSWORD}/g" ${propsFile} > server.properties
        chown -R ${user}:${group} ${stateDirectory}
      '' + (lib.optionalString (ramfsDirectory != null) ''
        [[ -d "${ramfsDirectory}" ]]
        rsync -aH --delete ${stateDirectory}/. ${ramfsDirectory}/
        chown -R ${user}:${group} ${ramfsDirectory}
      ''));
      postStopScript = pkgs.writeShellScript "mc-${name}-poststop" (if ramfsDirectory != null then ''
        if [[ "$(ls -1A "${ramfsDirectory}")" ]]; then
          rm -rf "${ramfsDirectory}"/*
        fi
      '' else "true");
      startCommand = if launchCommand == null then
        "java -Xmx${memStr} -Xms${memHalfStr} ${commonArgs} -jar ${jar} nogui"
        else
        launchCommand;
    in
    {
      description = serverProperties.motd;
      aliases = [ "mc-${name}.service" ];
      after = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      path = [ jre pkgs.util-linux pkgs.rsync pkgs.mcrcon pkgs.gnused ];
      unitConfig.RequiresMountsFor = lib.optionalString (ramfsDirectory != null) ramfsDirectory;

      script =
        if ramfsDirectory != null then ''
          savemc () {
            echo Syncing data
            ${mcrcon} -w 5 save-all save-off || true
            if ! rsync -vaH --delete ${ramfsDirectory}/. ${stateDirectory}/; then
              ${mcrcon} "say Something went wrong saving the game, tell admin. $(date +'%F %X')"
            fi
          }

          cd ${ramfsDirectory}
          export RUN=run.txt
          touch $RUN

          (
            while test -e $RUN; do
              # Sleep for 3 mins, but monitor run.txt
              for i in {1..180}; do
                if test -e $RUN; then
                  sleep 1
                else
                  break
                fi
              done
              savemc
            done
          ) &

          ${startCommand}

          rm $RUN
          echo Gracefully shutting down
          wait %1
        '' else startCommand;

      preStop = ''
        ${mcrcon} -w 5 "say Server shutting down in 10 seconds" save-all stop
        tail --pid=$MAINPID -f /dev/null
      '';

      serviceConfig = {
        MemoryMax = "${builtins.toString (memGb + 2)}G";
        CPUWeight = 40;
        Restart = "always";
        RestartSec = 10;
        User = user;
        Group = group;
        UMask = 0002;
        WorkingDirectory = stateDirectory;
        PrivateTmp = false;
        ExecStartPre = "+" + preStartScript;
        ExecStopPost = "+" + postStopScript;
        TimeoutStopSec = 120;
        EnvironmentFile = secretsFile;
      };
    };
}
