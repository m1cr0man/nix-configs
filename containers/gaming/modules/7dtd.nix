{ pkgs, ... }: let
  installdir = "/var/lib/gaming/7dtd-gary";
in {
  users.users.sevendays = {
    isSystemUser = true;
    group = "sevendays";
    home = installdir;
  };
  users.groups.sevendays = {};

  networking.firewall.allowedTCPPorts = [
    26900 26901 26902 26903 26904 26905
    27015 27016 27017 27018 27019 27020
    # web UI - do NOT add to the container port forwards
    8989
  ];
  networking.firewall.allowedUDPPorts = [
    26900 26901 26902 26903 26904 26905
    27015 27016 27017 27018 27019 27020
  ];

  environment.systemPackages = [ pkgs.inetutils pkgs.socat pkgs.steamcmd ];

  systemd.services.sevendays_gary = {
    description = "7 Days To Die Rebirth";
    wants = ["network.target"];
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      MALLOC_CHECK_ = "0";
      LD_LIBRARY_PATH = ".";
      CONFIGFILE = "serverconfig.xml";
    };
    serviceConfig = {
      WorkingDirectory = installdir;
      ExecStart = "${pkgs.steam-run}/bin/steam-run ${installdir}/7DaysToDieServer.x86_64 -configfile=serverconfig.xml -logfile 7dtd.log -quit -batchmode -nographics -dedicated";
      Restart = "always";
      RestartSec = "10";
      User = "sevendays";
      Group = "sevendays";
    };
  };

  systemd.timers.sevendays_abs = {
    timerConfig.OnCalendar = "minutely";
    partOf = [ "sevendays_gary.service" ];
    wantedBy = [ "sevendays_gary.service" ];
    after = [ "sevendays_gary.service" ];
  };

  systemd.services.sevendays_abs = {
    description = "Anti-Bob Script";
    requisite = ["sevendays_gary.service"];
    path = [ pkgs.inetutils pkgs.gnugrep pkgs.expect pkgs.gawk ];
    serviceConfig = {
      WorkingDirectory = installdir;
      Restart = "on-failure";
      RestartSec = "10";
      User = "sevendays";
      Group = "sevendays";
      EnvironmentFile = "${installdir}/telnet.env";
    };
    script = ''
      TELNET_HOST="localhost"
      TELNET_PORT="8988"
      PLAYER_CHECK_COMMAND="listplayers"
      TIMER_FILE="7dtd_abs_single_player_timer"
      PLAYER_ID_FILE="7dtd_abs_single_player_id"
      TIME_LIMIT=$((25 * 60))  # 25 minutes in seconds

      # Run telnet command via expect
      OUTPUT=$(expect << EOF
      log_user 0
      spawn telnet $TELNET_HOST $TELNET_PORT
      expect {
          "password:" { send "$TELNET_PASS\r"; exp_continue }
          "Press 'help'" { send "$PLAYER_CHECK_COMMAND\r" }
      }
      expect "in the game"
      set result \$expect_out(buffer)
      puts \$result
      exit 0
      EOF
      )

      # Extract player count
      PLAYER_COUNT=$(echo "$OUTPUT" | grep -oE "Total of [0-9]+" | awk '{print $3}')
      PLAYER_COUNT=''${PLAYER_COUNT:-0}

      # Extract the single player's entity ID if exactly one player is online
      if [ "$PLAYER_COUNT" -eq 1 ]; then
          PLAYER_ID=$(echo "$OUTPUT" | grep -oE "id=[0-9]+" | head -n1 | cut -d= -f2)
      fi

      # --- Logic for single‑player detection ---

      if [ "$PLAYER_COUNT" -eq 1 ]; then
          # If timer file doesn't exist, create it
          if [ ! -f "$TIMER_FILE" ]; then
              date +%s > "$TIMER_FILE"
              echo "$PLAYER_ID" > "$PLAYER_ID_FILE"
              echo "Single player detected. Timer started."
              exit 0
          fi

          # Check if it's the same player as before
          PREV_PLAYER_ID=$(cat "$PLAYER_ID_FILE")
          if [ "$PREV_PLAYER_ID" != "$PLAYER_ID" ]; then
              # New player → reset timer
              date +%s > "$TIMER_FILE"
              echo "$PLAYER_ID" > "$PLAYER_ID_FILE"
              echo "Different single player detected. Timer reset."
              exit 0
          fi

          # Calculate elapsed time
          START_TIME=$(cat "$TIMER_FILE")
          NOW=$(date +%s)
          ELAPSED=$((NOW - START_TIME))

          if [ "$ELAPSED" -ge "$TIME_LIMIT" ]; then
              echo "Single player has been online for 20 minutes. Kicking player $PLAYER_ID."

              # Kick the player
              expect << EOF
      log_user 0
      spawn telnet $TELNET_HOST $TELNET_PORT
      expect {
          "password:" { send "$TELNET_PASS\r"; exp_continue }
          "Press 'help'" {
            send "kick $PLAYER_ID\r\n"
            exit 0
          }
      }
      EOF

              # Reset timer
              rm -f "$TIMER_FILE" "$PLAYER_ID_FILE"
          else
              echo "Single player online for $ELAPSED seconds. Not kicking yet."
          fi

      else
          # Reset timer if 0 or >1 players online
          rm -f "$TIMER_FILE" "$PLAYER_ID_FILE" 2>/dev/null
          echo "Player count is $PLAYER_COUNT. Timer reset."
      fi
    '';
  };
}
