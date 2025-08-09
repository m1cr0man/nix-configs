{ config, pkgs, ... }:
let
  share = path: comment: {
    inherit path comment;
  };

  mkUser = name: uid: {
    inherit name uid;
    home = "/zhuge2/zstorage/users/${name}";
    useDefaultShell = true;
    group = name;
    extraGroups = [ "users" "wheel" ];
    isNormalUser = true;
  };
in
{
  sops.secrets.samba_passwords = {};

  m1cr0man.samba-shares = {
    games = (share "/zhuge2/games" "Games") // {
      extraConfig = {
        # TODO force user
        "guest ok" = "yes";
      };
    };
    apps_drivers = share "/zhuge2/apps_drivers" "Apps and Drivers";
    games_stuff = share "/zhuge2/games_stuff" "Games Stuff";
    movies = share "/zhuge2/movies" "Movie backups";
    music = share "/zhuge2/music" "Music backups";
    pc_backups = share "/zhuge2/pc_backups" "Computer backups";
    pictures_videos = share "/zhuge2/pictures_videos" "Pictures and Videos";
    sites = share "/zhuge2/sites" "Websites";
    quick_share = (share "/zhuge2/quick_share" "Quick Share") // {
      extraConfig = {
        "guest ok" = "yes";
      };
    };
  };

  users.users = {
    lucas = mkUser "lucas" 1000;
    zeus = mkUser "zeus" 1001;
    adam = mkUser "adam" 1002;
    sophie = mkUser "sophie" 1003;
  };

  users.groups = {
    lucas.gid = 1000;
    zeus.gid = 1001;
    adam.gid = 1002;
    sophie.gid = 1003;
  };

  systemd.services.samba-set-passwords = {
    description = "Set Samba user passwords";
    wantedBy = [ "samba-smbd.service" ];
    after = [ "samba-smbd.service" ];
    path = [ pkgs.samba ];
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.samba_passwords.path;
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      smbpasswd -a lucas << EOF
      $LUCAS_PASSWORD
      $LUCAS_PASSWORD

      EOF
    '';
  };
}
