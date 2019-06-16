let
    newpkg = import ./pkgs-override.nix;
    m1cr0blog = newpkg."m1cr0blog-1.2.1";
in {
  systemd.services.m1cr0blog = {
    description = "Personal blog";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = { NODE_ENV = "production"; };

    serviceConfig = {
        ExecStart = "${pkgs.nodejs-11_x}/bin/node ${m1cr0blog}/dist/index.js";
        User = "m1cr0blog";
        Restart = "always";
        WorkingDirectory = "/zstorage/m1cr0blog";
    };
  };

  security.acme.certs."m1cr0man.com".extraDomains."www.m1cr0man.com" = null;
  services.httpd.virtualHosts = [{
    enableSSL = true;
    hostName = "m1cr0man.com";
    serverAliases = [ "www.m1cr0man.com" ];
    extraConfig = "ProxyPass / http://127.0.0.1:3000/";
  }];
}
