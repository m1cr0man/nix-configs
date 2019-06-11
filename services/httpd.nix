{ config, pkgs, ... }:
{
  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 50;
    enableSSL = true;

    virtualHosts = [{
      hostName = "m1cr0man.com"
      sslServerKey = 
    }];

    adminAddr = "lucas+httpd@m1cr0man.com";
    hostName = "m1cr0man.com";
    #serverAliases = [ "${config.networking.hostName}.m1cr0man.com" "localhost" ];

    listen = [{ port = 80; } { port = 443; }];
  };
}
