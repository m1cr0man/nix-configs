{ config, pkgs, lib, ... }:
let
  secrets = import ../common/secrets.nix;
in {
  # Allow telegraf to read logs
  systemd.tmpfiles.rules = [
    "d '${config.services.httpd.logDir}' 0755 ${config.services.httpd.user} ${config.services.httpd.group} - -"
  ];

  services.httpd = {
    enable = true;
    mpm = "event";
    maxClients = 500;
    logFormat = "combinedplus";

    extraConfig = ''
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %v" combinedplus
      ProxyPreserveHost On
      DirectoryIndex index.php index.html index.htm index.shtml
    '';

    # Vhost for server status
    virtualHosts."127.0.0.1" = {
      extraConfig = ''
        <Location "/.server-status">
          SetHandler server-status
          AuthType Basic
          AuthName "Login for status"
          AuthUserFile "${pkgs.writeText "status-htpasswd" secrets.generic_htpasswd}"
          <RequireAny>
            Require ip 127.0.0.1
            Require valid-user
          </RequireAny>
        </Location>
      '';
    };

    adminAddr = "lucas+httpd@m1cr0man.com";

    # Only acme certs and status are accessible via port 80,
    # everything else is explicitly upgraded to https
  };

  # Monitoring
  services.telegraf.extraConfig.inputs.apache = {
    urls = [ "http://127.0.0.1/.server-status?auto" ];
  };

  services.telegraf.extraConfig.inputs.tail = [{
    files = [ (config.services.httpd.logDir + "/access.log") ];
    data_format = "grok";
    grok_patterns = [ "%{COMBINED_LOG_FORMAT} %{DATA:vhost}" ];
  } {
    files = [ (config.services.httpd.logDir + "/error.log") ];
    data_format = "grok";
    grok_patterns = [ "%{HTTPD24_ERRORLOG}" ];
  }];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
