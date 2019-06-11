{ config, pkgs, ... }:
let
  certsDir = "/var/lib/acme";
  webrootDir = certsDir + "/.webroot";
in {
  security.acme.certs."m1cr0man.com" = {
    email = "lucas+acme@m1cr0man.com";
    webroot = webrootDir;
    postRun = "systemctl reload httpd.service";
  };
  security.acme.directory = certsDir;

  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 50;
    sslServerKey = "${certsDir}/m1cr0man.com/key.pem";
    sslServerCert = "${certsDir}/m1cr0man.com/fullchain.pem";

    extraConfig = ''
      ProxyPreserveHost On
    '';

    # Only acme certs are accessible via port 80,
    # everything else is explicitly upgraded to https
    virtualHosts = [{
      hostName = "m1cr0man.com";
      serverAliases = [ "*.m1cr0man.com" ];
      servedDirs = [{
        urlPath = "/.well-known/acme-challenge";
        dir = "${webrootDir}/.well-known/acme-challenge";
      }];

      extraConfig = ''
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteCond %{REQUEST_URI} !^/\.well-known/.*$ [NC]
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301]
      '';
    }];

    adminAddr = "lucas+httpd@m1cr0man.com";
    hostName = "localhost";

    listen = [{ port = 80; }];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
