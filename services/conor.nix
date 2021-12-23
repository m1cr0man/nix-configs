{
  security.acme.certs."m1cr0man.com".extraDomainNames = [ "foundry.conor.m1cr0man.com" ];
  services.httpd.virtualHosts."foundry.conor.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = ''
      RewriteEngine On

      RewriteCond %{HTTP:Upgrade} =websocket [NC]
      RewriteRule /(.*)           ws://127.0.0.1:30000/$1 [P,L]
      RewriteCond %{HTTP:Upgrade} !=websocket [NC]
      RewriteRule /(.*)           http://127.0.0.1:30000/$1 [P,L]

      ProxyPass / http://127.0.0.1:30000/
      ProxyPassReverse / http://127.0.0.1:30000/
    '';
  };
}
