{
  security.acme.certs."m1cr0man.com".extraDomainNames = [ "breogan.m1cr0man.com" ];
  services.httpd.virtualHosts."breogan.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:1357/";
  };
}
