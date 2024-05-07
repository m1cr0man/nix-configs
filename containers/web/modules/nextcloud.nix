{ domain, config, pkgs, lib, ... }:
let
  sopsPerms = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  home = config.users.users.nextcloud.home;

  cfgImaginary = config.services.imaginary;
  imaginaryAddr = "http://${cfgImaginary.address}:${builtins.toString cfgImaginary.port}";

  cfgRedis = config.services.redis.servers.nextcloud;

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

  users.users.nextcloud.extraGroups = [ "sockets" "keys" ];
  users.groups.nextcloud.members = [ config.services.httpd.user ];

  # Ensure postgres is running before nextcloud-setup is run
  systemd.services.nextcloud-setup = {
    after = [ "postgresql-wait.service" ];
    requires = [ "postgresql-wait.service" ];
  };

  # Use httpd > nginx
  services.nginx.enable = false;
  services.phpfpm.pools.nextcloud = {
    phpEnv.PATH = lib.mkForce (lib.makeBinPath [
      pkgs.unrar
      pkgs.p7zip
      pkgs.ffmpeg_7-headless
      "/run/wrappers"
      "/nix/var/nix/profiles/default"
      "/run/current-system/sw"
    ]);
    settings = {
      "listen.owner" = config.services.httpd.user;
      "listen.group" = config.services.httpd.group;
      "pm.max_children" = lib.mkForce 125;
      "pm.start_servers" = lib.mkForce 10;
      "pm.min_spare_servers" = lib.mkForce 10;
      "pm.max_spare_servers" = lib.mkForce 75;
     };
  };

  # Thumbnail generator
  services.imaginary = {
    enable = true;
    port = 12380;
    settings.return-size = true;
  };

  # Caching and locking
  services.redis.servers.nextcloud = {
    enable = true;
    user = "nextcloud";
    port = 0;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    hostName = "nextcloud.${domain}";
    https = true;
    maxUploadSize = "4100M";
    caching.redis = true;

    settings = {
      default_phone_region = "IE";
      log_type = "file";
      maintenance_window_start = 1;

      # Previews/thumbnails
      preview_imaginary_url = imaginaryAddr;
      preview_format = "webp";
      preview_max_memory = 2048;
      enabledPreviewProviders = [
        "OC\\Preview\\MP3"
        "OC\\Preview\\TXT"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\Krita"
        "OC\\Preview\\Imaginary"
        "OC\\Preview\\Font"
        "OC\\Preview\\Illustrator"
        "OC\\Preview\\Movie"
        "OC\\Preview\\MP4"
        "OC\\Preview\\MSOffice2003"
        "OC\\Preview\\MSOffice2007"
        "OC\\Preview\\MSOfficeDoc"
        "OC\\Preview\\PDF"
        "OC\\Preview\\Photoshop"
        "OC\\Preview\\Postscript"
        "OC\\Preview\\StarOffice"
      ];

      # Caching
      "filelocking.enabled" = true;
      "memcache.locking" = "\\OC\\Memcache\\Redis";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.local" = "\\OC\\Memcache\\Redis";
      redis = {
        host = cfgRedis.unixSocket;
        port = 0;
      };
    };

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/var/lib/sockets";
      dbname = "nextcloud";
      dbpassFile = config.sops.secrets.nextcloud_database_password.path;
      adminpassFile = config.sops.secrets.nextcloud_root_password.path;
      adminuser = "root";
    };

    phpOptions = {
      "opcache.save_comments" = 60;
      "opcache.revalidate_freq" = 60;
      "opcache.interned_strings_buffer" = 32;
      "opcache.validate_timestamps" = 0;
      "session.save_handler" = "redis";
      "session.save_path" = "\"unix://${cfgRedis.unixSocket}?persistent=1&database=1\"";
      "redis.session.locking_enabled" = 1;
      "redis.session.lock_retries" = -1;
      "redis.session.lock_wait_time" = 10000;
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
