# Mostly a clone of the nixpkgs minecraft role to support
# multiple servers.
{ pkgs, lib }:
let
  mcRoot = "/var/gaming/minecraft";
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
  minecraftService = { name, memGb, jar, serverProperties, user, group, jre, zramSizeGb, zramDevice, secretsFile }:
    let
      serverRoot = mcRoot + "/${name}";
      memStr = "${builtins.toString memGb}G";
      memHalfStr = "${builtins.toString (memGb / 2)}G";
      propsFile = serverPropertiesFile serverProperties;
      mcrcon = "mcrcon -s -P ${builtins.toString serverProperties."rcon.port"} -p \"$RCON_PASSWORD\"";
      zramMount = "/tmp/zram-mc-${name}";
      zramResetCommands = ''
        if [ -e ${zramDevice} ]; then
          umount ${zramDevice} || true
        fi
      '';
      preStartScript = pkgs.writeShellScript "mc-${name}-prestart" (''
        set -euxo pipefail
        mkdir -p ${serverRoot}
        cd ${serverRoot}
        echo eula=true > eula.txt
        sed "s/RCON_PASSWORD_RUNTIME/''${RCON_PASSWORD}/g" ${propsFile} > server.properties
        chown -R ${user}:${group} ${serverRoot}
      '' + (lib.optionalString (zramSizeGb > 0) ''
        ${zramResetCommands}
        zramctl --size ${builtins.toString zramSizeGb}G --algorithm zstd ${zramDevice}
        mkfs.ext4 -F ${zramDevice}
        mkdir -p ${zramMount}
        mount ${zramDevice} ${zramMount}
        rsync -aH --delete ${serverRoot}/. ${zramMount}/
        chown -R ${user}:${group} ${zramMount}
      ''));
      postStopScript = pkgs.writeShellScript "mc-${name}-poststop" (if zramSizeGb > 0 then zramResetCommands else "true");
    in
    {
      description = serverProperties.motd;
      aliases = [ "mc-${name}.service" ];
      after = [ "network.target" "local-fs.target" "zram-reloader.service" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      path = [ jre pkgs.util-linux pkgs.e2fsprogs pkgs.rsync pkgs.mcrcon pkgs.gnused ];

      script =
        if zramSizeGb > 0 then ''
          savemc () {
            echo Syncing data
            ${mcrcon} -w 5 save-all save-off || true
            if ! rsync -vaH --delete ${zramMount}/. ${serverRoot}/; then
              ${mcrcon} "say Something went wrong saving the game, tell admin. $(date +'%F %X')"
            fi
          }

          cd ${zramMount}
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

          java -Xmx${memStr} -Xms${memHalfStr} ${commonArgs} -jar ${jar} nogui

          rm $RUN
          echo Gracefully shutting down
          wait %1
        '' else ''
          cd ${serverRoot}
          java -Xmx${memStr} -Xms${memHalfStr} ${commonArgs} -jar ${jar} nogui
        '';

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
        WorkingDirectory = lib.mkIf (zramSizeGb == 0) serverRoot;
        PrivateTmp = false;
        ExecStartPre = "+" + preStartScript;
        ExecStopPost = "+" + postStopScript;
        TimeoutStopSec = 120;
        EnvironmentFile = secretsFile;
      };
    };
}
