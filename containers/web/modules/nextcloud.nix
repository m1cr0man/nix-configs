{ domain, config, pkgs, lib, ... }:
let
  sopsPerms = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  home = config.users.users.nextcloud.home;
in
{
  sops.secrets.nextcloud_database_password = sopsPerms;
  sops.secrets.nextcloud_root_password = sopsPerms;

  users.users.nextcloud.extraGroups = [ "sockets" ];
  users.groups.nextcloud.members = [ config.services.httpd.user ];

  # Ensure postgres is running before nextcloud-setup is run
  systemd.services.nextcloud-setup.preStart = ''
    while test ! -e /var/lib/sockets/.s.PGSQL.5432; do
      echo "Waiting for PostgreSQL socket"
    done
  '';

  # Use httpd > nginx
  services.nginx.enable = false;
  services.phpfpm.pools.nextcloud = {
    phpEnv.PATH = lib.mkForce (builtins.concatStringsSep ":" [
      pkgs.unrar
      pkgs.p7zip
      "/run/wrappers/bin"
      "/nix/var/nix/profiles/default/bin"
      "/run/current-system/sw/bin"
      "/usr/bin"
      "/bin"
    ]);
    settings = {
      "listen.owner" = config.services.httpd.user;
      "listen.group" = config.services.httpd.group;
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud24;
    hostName = "nextcloud.${domain}";
    https = true;

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/var/lib/sockets";
      dbport = 5432;
      dbname = "nextcloud";
      dbpassFile = config.sops.secrets.nextcloud_database_password.path;
      adminpassFile = config.sops.secrets.nextcloud_root_password.path;
      adminuser = "root";
    };
  };

  services.httpd = {
    extraModules = [ "proxy_fcgi" ];
    virtualHosts."${config.services.nextcloud.hostName}" = lib.m1cr0man.makeVhost {
      documentRoot = config.services.nextcloud.package;

      # Port of the nginx config from
      # https://github.com/NixOS/nixpkgs/blob/38860c9e91cb00f4d8cd19c7b4e36c45680c89b5/nixos/modules/services/web-apps/nextcloud.nix#L914
      locations = {
        "/.well-known" = {
          priority = 210;
          extraConfig = ''
            Redirect permanent /.well-known/carddav /remote.php/dav
            Redirect permanent /.well-known/caldav /remote.php/dav
            Redirect permanent /.well-known/pki-validation /index.php
          '';
        };
        "~ \"^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)\"".extraConfig = ''
          Require all denied
        '';
        "~ \"^/(?:\.autotest|occ|issue|indie|db_|console)\"".extraConfig = ''
          Require all denied
        '';
        "~ \"^\\/(?:index|remote|public|cron|core\\/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|oc[ms]-provider\\/.+|.+\\/richdocumentscode\\/proxy)\\.php(?:$|\\/)\"" = {
          priority = 500;
          extraConfig = ''
            SetHandler "proxy:unix:${config.services.phpfpm.pools.nextcloud.socket}|fcgi://localhost/"
          '';
        };
      };
      # Taken from NixOS manual
      extraConfig = ''
        Alias /store-apps "${home}/store-apps"
        <Directory "${home}/store-apps">
          Require all granted
          Options +FollowSymLinks
        </Directory>

        Alias /nix-apps "${home}/nix-apps"
        <Directory "${home}/nix-apps">
          Require all granted
          Options +FollowSymLinks
        </Directory>

        # TODO try_files directive from L983
        <Directory "${config.services.nextcloud.package}">
          DirectoryIndex index.php
          Require all granted
          Options +FollowSymLinks
        </Directory>
      '';
    };
  };
}
