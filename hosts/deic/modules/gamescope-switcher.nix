{ pkgs, ... }: let
  startScript = pkgs.writeShellScript "xinitrc-deck-gnome" ''
    exec ${pkgs.steam}/bin/steam -silent &
    exec ${pkgs.gnome.gnome-session}/bin/gnome-session
  '';
in {
  services.xserver = {
    displayManager.lightdm.enable = false;
    displayManager.startx.enable = true;
  };

  systemd.services.gamescope-switcher = {
    enable = true;
    after = [
      "systemd-user-sessions.service"
      "plymouth-start.service"
      "plymouth-quit.service"
      "systemd-logind.service"
      "getty@tty1.service"
    ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-quit.service"];
    wantedBy = [ "graphical.target" ];
    partOf = [ "graphical.target" ];
    conflicts = [
      # Ensure there's no login prompt on the screen used for steam.
      "getty@tty7.service"
      # Ensures we don't run at the same time as display manager
      "display-manager.service"
    ];
    restartIfChanged = false;
    unitConfig.ConditionPathExists = "/dev/tty7";
    serviceConfig = {
      User = "deck";
      PAMName = "login";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";

      Restart = "always";
    };

    script = ''
      set-session () {
        mkdir -p ~/.local/state
        >~/.local/state/steamos-session-select echo "$1"
      }
      consume-session () {
        if [[ -e ~/.local/state/steamos-session-select ]]; then
          cat ~/.local/state/steamos-session-select
          rm ~/.local/state/steamos-session-select
        else
          echo "gamescope"
        fi
      }
      while :; do
        session=$(consume-session)
        case "$session" in
          desktop)
            startx ${startScript}
            set-session gamescope
            ;;
          gamescope)
            steam-session
            set-session desktop
            ;;
        esac
      done
    '';
  };
}
