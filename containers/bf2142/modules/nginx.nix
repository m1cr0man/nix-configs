{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "auth.pubsvs.gamespy.com" = {
        serverAliases = [ "*.auth.pubsvs.gamespy.com" ];
        extraConfig = ''
          server_tokens off;
        '';
        locations."/" = {
          uwsgiPass = "unix:/run/uwsgi/authservice.sock";
          recommendedUwsgiSettings = true;
        };
      };

      "d2g.pubsvs.gamespy.com" = {
        serverAliases = [ "*.d2g.pubsvs.gamespy.com" ];
        extraConfig = ''
          server_tokens off;
        '';
        locations."/" = {
          uwsgiPass = "unix:/run/uwsgi/commerceservice.sock";
          recommendedUwsgiSettings = true;
        };
      };

      "comp.pubsvs.gamespy.com" = {
        serverAliases = [ "*.comp.pubsvs.gamespy.com" ];
        extraConfig = ''
          server_tokens off;
        '';
        locations."/" = {
          uwsgiPass = "unix:/run/uwsgi/competitionservice.sock";
          recommendedUwsgiSettings = true;
        };
      };

      "sake.gamespy.com" = {
        serverAliases = [ "*.sake.gamespy.com" ];
        extraConfig = ''
          server_tokens off;
        '';
        locations."/" = {
          uwsgiPass = "unix:/run/uwsgi/storageservice.sock";
          recommendedUwsgiSettings = true;
        };
      };

      "motd.gamespy.com" = {
        serverAliases = [
          "*.motd.gamespy.com"
          "gamespyarcade.com"
          "www.gamespyarcade.com"
        ];
        extraConfig = ''
          server_tokens off;
        '';
        locations."/" = {
          proxyPass = "http://localhost:4000";
          extraConfig = ''
            proxy_hide_header X-Powered-By;
          '';
        };
      };

      "stella.prod.gamespy.com" = {
        extraConfig = ''
          server_tokens off;
        '';
        locations."/" = {
          proxyPass = "http://localhost:4001";
          extraConfig = ''
            proxy_hide_header X-Powered-By;
          '';
        };
      };
    };
  };
}
