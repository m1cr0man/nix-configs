let
  share = path: comment: {
    inherit path comment;
  };

  mkUser = name: uid: {
    inherit name uid;
    home = "/zhuge1/users/${name}";
    useDefaultShell = true;
    group = name;
    extraGroups = [ "users" "wheel" ];
    isNormalUser = true;
  };
in
{
  m1cr0man.samba-shares = {
    games = (share "/zhuge1/games" "Games") // {
      extraConfig = {
        # TODO force user
        "guest ok" = "yes";
      };
    };
    apps_drivers = share "/zhuge1/apps_drivers" "Apps and Drivers";
    games_stuff = share "/zhuge1/games_stuff" "Games Stuff";
    movies = share "/zhuge1/movies" "Movie backups";
    music = share "/zhuge1/music" "Music backups";
    pc_backups = share "/zhuge1/pc_backups" "Computer backups";
    pictures_videos = share "/zhuge1/pictures_videos" "Pictures and Videos";
    sites = share "/zhuge1/sites" "Websites";
    quick_share = (share "/zhuge1/quick_share" "Quick Share") // {
      extraConfig = {
        "guest ok" = "yes";
      };
    };
  };

  systemd.services.samba-smbd.unitConfig.ConditionPathIsMountPoint = "/zhuge1/users";

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
}
