{ config, lib, ... }:
let
  share = path: comment: {
    inherit path comment;
  };

  mkUser = name: uid: {
    inherit name uid;
    home = "/zhuge2/users/${name}";
    useDefaultShell = true;
    group = name;
    extraGroups = [ "users" "wheel" ];
    isNormalUser = true;
  };

  mkZhugeMounts = mounts: builtins.listToAttrs (
    builtins.map (mnt:
      {
        name = "/zhuge2/${mnt}";
        value = {
          device = "zhuge2/${mnt}";
          fsType = "zfs";
          options = [ "noatime" "nofail" ];
        };
      };
    )
    mounts
  );
in
{
  fileSystems = mkZhugeMounts [
    "games"
    "apps_drivers"
    "games_stuff"
    "movies"
    "music"
    "pc_backups"
    "pictures_videos"
    "plex"
    "plex/config"
    "plex/transcode"
    "quick_share"
    "sites"
    "users"
    "users/lucas"
    "users/zeus"
  ];

  nixos.containers.enableAutostartService = false;

  systemd.targets.zhuge2-autostart = {
    descrption = "Auto start zhuge2 container when zhuge2 is mounted";
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathIsMountPoint = "/zhuge2/users";
    after = [ "network-online.target" "zhuge2-users.mount" ];
    before = [ "systemd-nspawn@zhuge2.service" ];
    requires = [ "systemd-nspawn@zhuge2.service" ];
  };

  nixos.containers.instances.zhuge2 = {
    autoStart = false;

    bindMounts = [
      "/zhuge2:/zhuge2"
    ];

    forwardPorts =
      builtins.map
        (port: { hostPort = port; containerPort = port; })
        [
          137
          138
          139
          445
        ];

    system-config = {
      system.stateVersion = config.system.stateVersion;

      imports = with lib.m1cr0man.module;
        addModules ../../../modules [
          "servers/samba"
        ];

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

      services.zrepl = let
        pruningRules = [
          {
            # Keep all non-zrepl snaps
            type = "regex";
            negate = true;
            regex = "^zrepl_.*";
          }
          {
            type = "last_n";
            count = 5;
            regex = "^zrepl_.*";
          }
        ];
      in {
        enable = true;
        settings.jobs = [{
          name = "zhuge_push";
          type = "push";
          filesystems."zhuge2<" = true;
          connect = {
            type = "tcp";
            address = "sarah.lucas.ts.m1cr0man.com:11223";
          };
          send.compressed = true;
          pruning.keep_receiver = pruningRules;
          pruning.keep_sender = pruningRules;
          conflict_resolution.initial_replication = "all";
          snapshotting = {
            type = "periodic";
            timestamp_format = "human";
            prefix = "zrepl_";
            interval = "1d";
          };
        }];
      }
    };
  };
}
