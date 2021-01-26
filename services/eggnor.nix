{
  security.acme.certs."m1cr0man.com".extraDomainNames = [ "eggnor.m1cr0man.com" ];
  services.httpd.virtualHosts."eggnor.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:5120/";
  };
}
