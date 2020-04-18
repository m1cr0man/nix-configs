{
  security.acme.certs."m1cr0man.com".extraDomains."breogan.m1cr0man.com" = null;
  services.httpd.virtualHosts."breogan.m1cr0man.com" = {
    onlySSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = "ProxyPass / http://127.0.0.1:1357/";
  };
}
