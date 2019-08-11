{ config, pkgs, ... }:
let
  secrets = import ../common/secrets.nix;

  certsDir = "/var/lib/acme";

  webrootDir = certsDir + "/.webroot";

  acmeCert = {
    email = "lucas+acme@m1cr0man.com";
    webroot = webrootDir;
    postRun = "systemctl reload httpd.service";
  };

  acmeVhost = domain: {
      hostName = domain;
      serverAliases = [ "*.${domain}" ];
      servedDirs = [{
        urlPath = "/.well-known/acme-challenge";
        dir = "${webrootDir}/.well-known/acme-challenge";
      }];

      extraConfig = ''
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteCond %{REQUEST_URI} !^/\.well-known/.*$ [NC]
        RewriteCond %{REQUEST_URI} !^/\.server-status/?$ [NC]
        RewriteCond %{REQUEST_URI} !^/error/.*\.html\.var$ [NC]
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301]
      '';
    };
in {
  security.acme.directory = certsDir;
  security.acme.certs = {
    "m1cr0man.com" = acmeCert;
  };

  # Allow telegraf to read logs
  systemd.tmpfiles.rules = [
    "d '${config.services.httpd.logDir}' 0755 ${config.services.httpd.user} ${config.services.httpd.group} - -"
  ];

  # Clear log file regularly since telegraf streams it
  services.cron.systemCronJobs = [
    "0 4 * * * echo Log cleared by cron script > ${config.services.httpd.logDir}/access.log"
    "0 4 * * * echo Log cleared by cron script > ${config.services.httpd.logDir}/error.log"
  ];

  services.httpd = {
    enable = true;
    multiProcessingModule = "event";
    maxClients = 500;
    sslServerKey = "${certsDir}/m1cr0man.com/key.pem";
    sslServerCert = "${certsDir}/m1cr0man.com/fullchain.pem";
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

    virtualHosts = [
      (acmeVhost "m1cr0man.com")
      (acmeVhost "cragglerock.cf")
    ];

    adminAddr = "lucas+httpd@m1cr0man.com";
    hostName = "localhost";

    # Only acme certs and status are accessible via port 80,
    # everything else is explicitly upgraded to https
    listen = [{ port = 80; }];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
