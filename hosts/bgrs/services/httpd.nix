{ pkgs, ... }:
{
  imports = [ ../../../services/httpd.nix ];
  services.httpd = {
    enablePHP = true;
    phpPackage = pkgs.php80;
    phpOptions = ''
      extension=${pkgs.php80Extensions.pgsql}/lib/php/extensions/pgsql.so
    '';
    extraConfig = ''
      DavLockDB /var/www/davlock
    '';
    virtualHosts = {
      "192.168.137.5" = {
        documentRoot = "/var/www";
        extraConfig = ''
          # Let PHP generate DAV-compatible indexes
          DirectoryIndex disabled
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
    };
  };
}
