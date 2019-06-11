{ config, pkgs, ... }:
let
  certsDir = "/var/lib/acme";
  webrootDir = certsDir + "/.webroot";
in {
  security.acme.certs."*.m1cr0man.com" = {
    email = "lucas+acme@m1cr0man.com";
    webroot = webrootDir;
    postRun = "systemctl reload httpd.service";
  };
  security.acme.directory = certsDir;
  security.acme.production = false;

  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 50;
    enableSSL = true;
    sslServerKey = "${certsDir}/m1cr0man.com/key.pem";
    sslServerCert = "${certsDir}/m1cr0man.com/fullchain.pem";

    adminAddr = "lucas+httpd@m1cr0man.com";
    hostName = "m1cr0man.com";

    servedDirs = [{
      urlPath = "/.well-known/acme-challenge";
      dir = "${webrootDir}/.well-known/acme-challenge";
    }];

    listen = [{ port = 80; } { port = 443; }];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
