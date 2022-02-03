{ pkgs, lib, ... }:
with lib.m1cr0man;
{
  # Required by Akaunting
  systemd.services.httpd.path = [ pkgs.php80 pkgs.zip pkgs.unzip pkgs.gd ];

  services.httpd = {
    enablePHP = true;
    phpPackage = pkgs.php80;
    phpOptions = ''
      extension = ${pkgs.php80Extensions.pgsql}/lib/php/extensions/pgsql.so
      extension = ${pkgs.php80Extensions.gd}/lib/php/extensions/gd.so
      extension = ${pkgs.php80Extensions.zip}/lib/php/extensions/zip.so
      extension = ${pkgs.php80Extensions.pdo_mysql}/lib/php/extensions/pdo_mysql.so
      error_reporting = E_ALL & ~E_DEPRECATED
    '';
    extraConfig = ''
      DavLockDB /var/www/davlock
    '';
    virtualHosts = {
      "192.168.137.5" = {
        documentRoot = "/var/www";
        extraConfig = ''
          # Let Apache generate DAV-compatible indexes
          DirectoryIndex disabled
          php_admin_flag engine off
          <Directory "/var/www">
            Require all granted
            Dav On
          </Directory>
          <FilesMatch \.php$>
            SetHandler None
          </FilesMatch>
        '';
      };
      "brb" = {
        documentRoot = "/var/www/tw/www";
      };
      "repairs" = {
        documentRoot = "/var/www/repairs";
      };
      "domains" = {
        documentRoot = "/var/www/domains/www";
      };
      "bgrs" = {
        documentRoot = "/var/www/bgrs";
      };
      "partman" = {
        documentRoot = "/var/www/partman";
      };
      "akaunting" = {
        documentRoot = "/var/www/akaunting";
        extraConfig = ''
          <Directory "/var/www/akaunting">
            AllowOverride All
          </Directory>
        '';
      };
      "invoiceplane" = {
        documentRoot = "/var/www/invoiceplane";
        extraConfig = ''
          <Directory "/var/www/invoiceplane">
            AllowOverride All
          </Directory>
        '';
      };
      "ledgersmb" = (makeVhostProxy { host = "127.0.0.1:5762"; }) // {
        forceSSL = false;
        useACMEHost = null;
      };
    };
  };
}
