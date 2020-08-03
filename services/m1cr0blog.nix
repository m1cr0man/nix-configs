{ pkgs, ... }:
let
    newpkg = import ../packages/m1cr0blog/override.nix { inherit pkgs; };
    m1cr0blog = newpkg."m1cr0blog-1.2.2";
in {
  users.users.m1cr0blog = {
    description = "Service user for m1cr0blog";
    isSystemUser = true;
    shell = "/dev/null";
    home = "/dev/null";
  };

  systemd.services.m1cr0blog = {
    description = "Personal blog";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = { NODE_ENV = "production"; };

    serviceConfig = {
        ExecStart = "${m1cr0blog}/bin/m1cr0blog";
        User = "m1cr0blog";
        Restart = "always";
        WorkingDirectory = "/var/www/m1cr0blog";
    };
  };

  services.httpd.virtualHosts."m1cr0man.com" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "www.m1cr0man.com" ];
    extraConfig = "ProxyPass / http://127.0.0.1:3000/";
  };

  security.acme.certs."m1cr0man.com".extraDomainNames = ["u.m1cr0man.com" "dev.m1cr0man.com" ];

  services.httpd.virtualHosts."u.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    extraConfig = ''
      RewriteEngine On
      RewriteRule ^/?$ https://m1cr0man.com/ [R=301]
      ProxyPassMatch ^/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/?$ http://127.0.0.1:3000/upload/$1/$2
      ProxyPass / http://127.0.0.1:3000/
    '';
  };

  services.httpd.virtualHosts."dev.m1cr0man.com" = {
    forceSSL = true;
    useACMEHost = "m1cr0man.com";
    documentRoot = "/opt/generic/m1cr0blog_dev/dist";
  };
}
