{
  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 50;
    enableSSL = true;
    extraModules = [ "proxy" "proxy_http" "deflate" "cache" "proxy_html" ];

    adminAddr = "lucas+httpd@m1cr0man.com";
    hostName = "m1cr0man.com";
    serverAliases = [ "${networking.hostName}.m1cr0man.com" "localhost" ]

    listen.0.port = 80;
    listen.1.port = 443;
  }
}
