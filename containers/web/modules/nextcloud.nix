{ domain, config, pkgs, lib, ... }:
let
  sopsPerms = {
    owner = "nextcloud";
    group = "nextcloud";
  };
in
{
  sops.secrets.nextcloud_database_password = sopsPerms;
  sops.secrets.nextcloud_root_password = sopsPerms;

  users.users.nextcloud.extraGroups = [ "sockets" ];

  # Ensure postgres is running before nextcloud-setup is run
  systemd.services.nextcloud-setup.preStart = ''
    while test ! -e /var/lib/sockets/.s.PGSQL.5432; do
      echo "Waiting for PostgreSQL socket"
    done
  '';

  # Use httpd > nginx
  services.nginx.enable = false;
  services.phpfpm.pools.nextcloud.settings = {
    "listen.owner" = config.services.httpd.user;
    "listen.group" = config.services.httpd.group;
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
      # Taken from NixOS manual
      extraConfig = ''
        <Directory "${config.services.nextcloud.package}">
          <FilesMatch "\.php$">
            <If "-f %{REQUEST_FILENAME}">
              SetHandler "proxy:unix:${config.services.phpfpm.pools.nextcloud.socket}|fcgi://localhost/"
            </If>
          </FilesMatch>
          <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteBase /
            RewriteRule ^index\.php$ - [L]
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule . /index.php [L]
          </IfModule>
          DirectoryIndex index.php
          Require all granted
          Options +FollowSymLinks
        </Directory>
      '';
    };
  };
}
