let
  share = path: comment: {
    inherit path comment;
  };

  mkUser = name: uid: {
    inherit name uid;
    home = "/zhuge1/zstorage/users/${name}";
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
    apps_drivers = share "/zhuge1/zstorage/apps_drivers" "Apps and Drivers";
    games_stuff = share "/zhuge1/zstorage/games_stuff" "Games Stuff";
    movies = share "/zhuge1/zstorage/movies" "Movie backups";
    music = share "/zhuge1/zstorage/music" "Music backups";
    pc_backups = share "/zhuge1/zstorage/pc_backups" "Computer backups";
    pictures_videos = share "/zhuge1/zstorage/pictures_videos" "Pictures and Videos";
    sites = share "/zhuge1/zstorage/sites" "Websites";
    quick_share = (share "/zhuge1/zstorage/quick_share" "Quick Share") // {
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
}
