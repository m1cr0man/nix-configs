let
  share = path: comment: {
    inherit path comment;
    "valid users" = "@users";
    "guest ok" = "yes";
    "browseable" = "yes";
    "writeable" = "yes";
  };
in {
  services.samba = {
    enable = true;
    syncPasswordsByPam = true;
    shares = {
      homes = {
        comment = "Your personal folder";
        "valid users" = "%S, %D%w%S";
        "force group" = "%G";
        "browseable" = "no";
        "inherit acls" = "yes";
        "create mask" = "0700";
        "directory mask" = "0700";
        "force create mode" = "0700";
        "force directory mode" = "0700";
      };
      steam_master = share "/zgaming/steam/master" "Master Steam archive";
      origin_master = share "/zgaming/origin/master" "Master Origin archive";
      apps_drivers = share "/zstorage/apps_drivers" "Apps and Drivers";
      games_stuff = share "/zstorage/games_stuff" "Games Stuff";
      movies = share "/zstorage/movies" "Movie backups";
      music = share "/zstorage/music" "Music backups";
      pc_backups = share "/zstorage/pc_backups" "Computer backups";
      pictures_videos = share "/zstorage/pictures_videos" "Pictures and Videos";
      sites = share "/zstorage/sites" "Websites";
      quick_share = (share "/zstorage/quick_share" "Quick Share") // {
        "guest ok" = "yes";
      };
    };

    extraConfig = ''
      log file = /var/log/samba/log.%m
      log level = 2
      max log size = 50

      hosts allow = 192.168.14. 127.0.0.1 ::1
      hosts deny = all
      socket options = IPTOS_LOWDELAY SO_SNDBUF=131072 SO_RCVBUF=131072 TCP_NODELAY
      max connections = 0

      netbios name = INTERSECT
      workgroup = WORKGROUP
      server string = Intersect File Server

      domain master = no
      preferred master = yes
      os level = 4
      auto services = global
      server role = standalone server
      wins support = no
      dns proxy = no
      hostname lookups = no
      name resolve order = lmhosts bcast host wins

      passdb backend = tdbsam
      encrypt passwords = yes
      client use spnego = no
      max protocol = default
      min protocol = NT1
      server signing = no

      getwd cache = yes
      strict sync = no
      strict locking = no
      sync always = no

      min receivefile size = 16384
      use sendfile = yes
      aio read size = 16384
      aio write size = 16384

      kernel oplocks = no
      kernel share modes = no
      posix locking = no

      load printers = no
      printable = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes

      # Disable xattrs
      ea support = no
      store dos attributes = no
      map archive = no
      map hidden = no
      map readonly = no
      map system = no

      create mask = 0770
      directory mask = 0770
      force create mode = 0770
      force directory mode = 0770
      writable = yes
      browseable = yes
      force group = users
      guest account = smbguest

      usershare path = /var/lib/samba/usershares
      usershare max shares = 100
      usershare allow guests = yes
      usershare owner only = yes
    '';
  };

  users.users.smbguest = {
    uid = 1099;
    isSystemUser = true;
    group = "users";
    description = "Guest account for samba connections";
  };

  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
