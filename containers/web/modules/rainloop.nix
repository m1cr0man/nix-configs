{ domain, config, pkgs, lib, ... }:
let
  nextcloudPHP = config.services.phpfpm.pools.nextcloud;
in 
{
  users.users.rainloop = {
    isSystemUser = true;
    home = "/var/lib/rainloop";
    extraGroups = [ "sockets" ];
    group = "rainloop";
  };
  users.groups.rainloop.members = [ config.services.httpd.user ];

  services.phpfpm.pools.rainloop = {
    # Copy a lot of config from nextcloud
    user = "rainloop";
    group = "rainloop";
    settings = (builtins.removeAttrs nextcloudPHP.settings ["user" "group" "listen"]) // {
      "listen.owner" = "rainloop";
      "listen.group" = "rainloop";
    };
    inherit (nextcloudPHP) phpPackage phpEnv;
  };

  services.httpd = {
    extraModules = [ "proxy_fcgi" ];
    virtualHosts."mail.${domain}" = lib.m1cr0man.makeVhost {
      documentRoot = pkgs.rainloop-community;
      locations = {
        "~ \"^.*\\.php(?:$|\\/)\"" = {
          priority = 500;
          extraConfig = ''
            SetHandler "proxy:unix:${config.services.phpfpm.pools.rainloop.socket}|fcgi://localhost/"
          '';
        };
      };
      extraConfig = ''
        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"

        Header always add Access-Control-Allow-Headers "*"
        Header always add Access-Control-Allow-Methods "*"

        Header always set Access-Control-Allow-Origin "https://mail.${domain}" "expr=req('origin') == 'https://mail.${domain}'"
      '';
    };
  };
}
