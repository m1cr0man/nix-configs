{ config, pkgs, lib, ... }:
let
  secrets = import ../common/secrets.nix;
in {
  security.acme.acceptTerms = true;
  security.acme.email = "lucas+acme@m1cr0man.com";
  # security.acme.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

  # Allow telegraf to read logs
  systemd.tmpfiles.rules = [
    "d '${config.services.httpd.logDir}' 0755 ${config.services.httpd.user} ${config.services.httpd.group} - -"
  ];

  # Clear log file regularly since telegraf streams it
  # Also reload httpd to pick up new certs
  services.cron.systemCronJobs = [
    "0 4 * * * echo Log cleared by cron script > ${config.services.httpd.logDir}/access.log"
    "0 4 * * * echo Log cleared by cron script > ${config.services.httpd.logDir}/error.log"
    "0 6 * * 0 systemctl reload httpd.service"
  ];

  services.httpd = {
    enable = true;
    mpm = "event";
    maxClients = 500;
    logFormat = "combinedplus";

    extraConfig = ''
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %v" combinedplus
      ProxyPreserveHost On

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

    adminAddr = "lucas+httpd@m1cr0man.com";

    # Only acme certs and status are accessible via port 80,
    # everything else is explicitly upgraded to https
  };

  # Monitoring
  services.telegraf.inputs.apache = {
    urls = [ "http://127.0.0.1/.server-status?auto" ];
  };

  services.telegraf.inputs.tail = [{
    files = [ (config.services.httpd.logDir + "/access.log") ];
    data_format = "grok";
    grok_patterns = [ "%{COMBINED_LOG_FORMAT} %{DATA:vhost}" ];
  } {
    files = [ (config.services.httpd.logDir + "/error.log") ];
    data_format = "grok";
    grok_patterns = [ "%{HTTPD24_ERRORLOG}" ];
  }];

  # Certificates
  security.acme.certs."m1cr0man.com".group = lib.mkForce "acme";
  users.users.wwwrun.extraGroups = [ "acme" ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
