{ domain, config, pkgs, lib, ... }:
let
  sopsPerms = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  home = config.users.users.nextcloud.home;

  phpProxyConfig = ''
    RewriteEngine On
    RewriteCond %{HTTP:Authorization} ^(.*)
    RewriteRule .* - [e=HTTP_AUTHORIZATION:%1]

    RewriteCond %{HTTP:Origin} https://app.keeweb.info
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule .* - [R=204,NC,L]

    SetHandler "proxy:unix:${config.services.phpfpm.pools.nextcloud.socket}|fcgi://localhost/"
  '';
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
    package = pkgs.nextcloud26;
    hostName = "nextcloud.${domain}";
    https = true;
    logType = "file";
    maxUploadSize = "4100M";

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/var/lib/sockets";
      dbport = 5432;
      dbname = "nextcloud";
      dbpassFile = config.sops.secrets.nextcloud_database_password.path;
      adminpassFile = config.sops.secrets.nextcloud_root_password.path;
      adminuser = "root";
      defaultPhoneRegion = "IE";
    };
  };

  services.httpd = {
    extraModules = [ "proxy_fcgi" ];
    virtualHosts."${config.services.nextcloud.hostName}" = lib.m1cr0man.makeVhost {
      documentRoot = config.services.nextcloud.package;
      # Port of the nginx config from
      # https://github.com/NixOS/nixpkgs/blob/38860c9e91cb00f4d8cd19c7b4e36c45680c89b5/nixos/modules/services/web-apps/nextcloud.nix#L914
      locations = {
        "~ \"^\\/(?:index|remote|public|cron|core\\/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|oc[ms]-provider\\/.+|.+\\/richdocumentscode\\/proxy)\\.php(?:$|\\/)\"" = {
          priority = 500;
          extraConfig = phpProxyConfig;
        };
      };
      # Taken from NixOS manual
      extraConfig = ''
        Alias /store-apps "${home}/store-apps"
        <Directory "${home}/store-apps">
          Require all granted
          Options +FollowSymLinks
          AllowOverride All
        </Directory>

        Alias /nix-apps "${home}/nix-apps"
        <Directory "${home}/nix-apps">
          Require all granted
          Options +FollowSymLinks
          AllowOverride All
        </Directory>

        <Directory "${config.services.nextcloud.package}">
          Require all granted
          Options FollowSymLinks MultiViews
          AllowOverride All

          <IfModule mod_dav.c>
            Dav off
          </IfModule>
        </Directory>

        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"

        Header always add Access-Control-Allow-Headers "*"
        Header always add Access-Control-Allow-Methods "*"

        Header always set Access-Control-Allow-Origin "https://${config.services.nextcloud.hostName}" "expr=req('origin') == 'https://${config.services.nextcloud.hostName}'"
        Header always set Access-Control-Allow-Origin "https://app.keeweb.info" "expr=req('origin') == 'https://app.keeweb.info'"
      '';
    };
  };
}
