{ pkgs, config, lib, ... }:
let
  secrets = import ../common/secrets.nix;
  hostName = "nextcloud.m1cr0man.com";
  home = "/zstorage/nextcloud";

  # Fix around fcgi header changes.
  # See https://httpd.apache.org/docs/2.4/mod/mod_headers.html#header
  header = key: value: ''
    Header onsuccess unset ${key}
    Header always set ${key} "${value}"
  '';
in {
  services.httpd.extraModules = [ "proxy_fcgi" "deflate" "filter" ];

  services.nginx.user = "wwwrun";
  services.nginx.group = "wwwrun";

  users.extraUsers.nextcloud.group = lib.mkForce "wwwrun";
  users.groups.nginx.members = [ "wwwrun" "nextcloud" ];

  services.nextcloud = {
    inherit hostName home;
    enable = true;
    https = true;
    config = {
      adminpass = secrets.nextcloud_adminpass;
      overwriteProtocol = "https";
    };
  };

  security.acme.certs."m1cr0man.com".extraDomains."${hostName}" = null;
  services.httpd.virtualHosts = [{
    inherit hostName;
    documentRoot = pkgs.nextcloud;
    enableSSL = true;
    extraConfig = ''
      RewriteEngine On
      SSLProxyEngine on
      DeflateCompressionLevel 4
      Header always unset X-Powered-By
      Header always set Strict-Transport-Security 15552000
      Alias "/store-apps" "${home}/store-apps"

      AddOutputFilterByType DEFLATE application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy

      <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/phpfpm-nextcloud/nextcloud.sock|fcgi://localhost/"
      </FilesMatch>

      <Directory "${pkgs.nextcloud}">
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
      </Directory>

      <Directory "${home}">
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
      </Directory>

      <IfModule mod_dir.c>
        DirectorySlash off
      </IfModule>
    '';
  }];
}
