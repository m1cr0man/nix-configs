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

  # services.phpfpm.pools.nextcloud.group = "wwwrun";

  services.nextcloud = {
    inherit hostName home;
    enable = true;
    https = true;
    config = {
      adminpass = secrets.nextcloud_adminpass;
      overwriteProtocol = "https";
    };
    # poolSettings = {
    #   "listen.owner" = "wwwrun";
    #   "listen.group" = "wwwrun";
    # };

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

      <FilesMatch \.php$>
          SetHandler "proxy:unix:/run/phpfpm-nextcloud/nextcloud.sock|fcgi://localhost/"
      </FilesMatch>

      <IfModule mod_env.c>
        SetEnv front_controller_active true
      </IfModule>

      <IfModule mod_dir.c>
        DirectorySlash off
      </IfModule>

      <Directory ${home}>
        Options +Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
      </Directory>

      <Location "^/+(build|tests|config|lib|3rdparty|templates|data|autotest|occ|issue|indie|db_|console)/*">
        AllowOverride None
        Order deny,allow
        Deny from All
      </Location>

      <FilesMatch "^.*\.(css|js|woff2?|svg|gif)$">
        Options +FollowSymLinks
        ${header "Cache-Control" "public, max-age=15778643"}
      </FilesMatch>

      ${header "X-Content-Type-Options" "nosniff"}
      ${header "X-XSS-Protection" "1; mode=block"}
      ${header "X-Robots-Tag" "none"}
      ${header "X-Download-Options" "noopen"}
      ${header "X-Permitted-Cross-Domain-Policies" "none"}
      ${header "Referrer-Policy" "no-referrer"}
      Header always unset X-Powered-By

      AddOutputFilterByType DEFLATE application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

      RewriteRule ^/\.well-known/(card|cal)dav/?$ %{REQUEST_SCHEME}/%{HTTP_HOST}/remote.php/dav [END,R=301]
      RewriteRule ^/(updater|ocs-provider|ocm-provider)$ %{REQUEST_URI}/ [END]

      RewriteRule ^/store-app/(.*) ${home}/$1 [P,QSA,END]

      # Equivalent of try-files
      RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_URI} !-f
      RewriteRule ^(?!/[^\./]+\.php).*$ /index.php%{REQUEST_URI} [P,QSA,END]

      RewriteCond %{REQUEST_URI} /(?:index|remote|public|cron|core/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|ocs-provider\\/.+|ocm-provider\\/.+)\\.php/?$
      RewriteRule ^(?!/[^\./]+\.php).*$ /index.php%{REQUEST_URI} [P,QSA,END]
    '';
  }];
}
