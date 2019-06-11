{ config, pkgs, ... }:
let
  certsDir = "/var/lib/acme";
  webrootDir = certsDir + "/.webroot";
in {
  security.acme.certs."m1cr0man.com" = {
    email = "lucas@m1cr0man.com";
    webroot = webrootDir;
    extraDomains = {
      "u.m1cr0man.com" = null;
      "www.m1cr0man.com" = null;
      "s3.m1cr0man.com" = null;
    };
    postRun = "systemctl reload httpd.service";
  };
  security.acme.directory = certsDir;

  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 50;
    enableSSL = true;
    sslServerKey = "${certsDir}/m1cr0man.com/key.pem";
    sslServerCert = "${certsDir}/m1cr0man.com/fullchain.pem";

    extraConfig = ''
      RewriteEngine On
      RewriteCond ''${HTTPS} off
      RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    '';

    virtualHosts = [{
      hostName = "m1cr0man.com";
      servedDirs = [{
        urlPath = "/.well-known/acme-challenge";
        dir = "${webrootDir}/.well-known/acme-challenge";
      }];
    }
    ];

    adminAddr = "lucas+httpd@m1cr0man.com";
    hostName = "localhost";

    listen = [{ port = 80; } { port = 443; }];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
