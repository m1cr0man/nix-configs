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
  };
in {
  imports = [ ../../services/samba ];

  m1cr0man.samba-shares = {
    archives_master = share "/zhuge2/zgaming/archives/master" "Master old games archive";
    steam_master = share "/zhuge2/zgaming/steam/master" "Master Steam archive";
    origin_master = share "/zhuge2/zgaming/origin/master" "Master Origin archive";
    apps_drivers = share "/zhuge2/zstorage/apps_drivers" "Apps and Drivers";
    games_stuff = share "/zhuge2/zstorage/games_stuff" "Games Stuff";
    movies = share "/zhuge2/zstorage/movies" "Movie backups";
    music = share "/zhuge2/zstorage/music" "Music backups";
    pc_backups = share "/zhuge2/zstorage/pc_backups" "Computer backups";
    drive_c = share "/drive_c" "Old PC Drive C";
    pictures_videos = share "/zhuge2/zstorage/pictures_videos" "Pictures and Videos";
    sites = share "/zhuge2/zstorage/sites" "Websites";
    quick_share = (share "/zhuge2/zstorage/quick_share" "Quick Share") // {
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