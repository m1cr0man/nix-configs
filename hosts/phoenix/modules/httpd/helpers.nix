{ pkgs, config, lib }:
let
  httpdUser = config.services.httpd.user;
  httpdGroup = config.services.httpd.group;

  secureSystemdServiceConfig = { username, home }: {
      User = username;
      Group = username;
      # The NixOS module is hard-coded to have RuntimeDirectory=phpfpm
      RuntimeDirectoryMode = "0777";
      # Access write directories
      ProtectHome = lib.mkForce "tmpfs";
      BindPaths = [ home ];
      ReadWritePaths = [ home ];
      UMask = "0077";
      # Capabilities
      CapabilityBoundingSet = "";
      # Security
      NoNewPrivileges = true;
      # Sandboxing
      ProtectSystem = "full";
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      PrivateMounts = true;
      # System Call Filtering
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap";
  };

  mysqlConfig = { username }: {
    services.mysql = {
      ensureDatabases = [ username ];
      ensureUsers = [
        {
          name = username;
          ensurePermissions = {
            "${username}.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };

  postgresqlConfig = { username }: {
    services.postgresql = {
      ensureDatabases = [ username ];
      ensureUsers = [
        {
          name = username;
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };
  };

  phpConfig = { username, domain, home }: {
    services.phpfpm.pools.${username} = {
      user = username;
      group = username;
      settings = {
        "catch_workers_output" = "yes";
        "pm" = "ondemand";
        "pm.process_idle_timeout" = "1m";
        "pm.max_children" = "5";
        "pm.max_requests" = "100";
      };
      phpOptions = ''
        mail.log = "/home/${username}/phpmail.log"
        upload_max_filesize = 50M;
        post_max_size = 50M;
        memory_limit = 55M;
      '';
    };

    systemd.services."phpfpm-${username}".serviceConfig = secureSystemdServiceConfig { inherit username home; };
  };

  wordpressConfig = { username, domain, home }: {
    vcc.wordpressSites.${username} = domain;

    systemd.services."wp-cron-${username}" = {
      description = "Runs wp-cron.php for ${domain}.";
      requires = [ "wordpress-setup.service" ];
      after = [ "wordpress-setup.service" ];
      serviceConfig = (secureSystemdServiceConfig { inherit username home; }) // {
        Type = "oneshot";
        WorkingDirectory = "${home}/public_html";
        ExecStart = "${config.services.phpfpm.phpPackage}/bin/php wp-cron.php";
      };
    };

    systemd.timers."wp-cron-${username}" = {
      description = "Runs wp-cron.php for ${domain} every 5 minutes.";
      after = [ "local-fs.target" "network.target" ];
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "*:5/10";
    };
  };

  rewriteRules = primaryDomain: ''
    RewriteEngine on
    RewriteCond %{HTTP:Authorization} ^(.*)
    RewriteRule .* - [e=HTTP_AUTHORIZATION:%1]
    RewriteCond %{HTTP_HOST} !^${primaryDomain} [NC]
    RewriteRule (.*) %{REQUEST_SCHEME}://${primaryDomain}%{REQUEST_URI} [L,R=301]
  '';
in {
  inherit rewriteRules;

  # TODO
  # - Add per-user database backup directory
  # - Add per-user logs for httpd, php, msmtp
  mkDomain = {
    username,
    domain,
    primaryDomain ? domain,
    wordpress ? false,
    php ? wordpress,
    mysql ? wordpress,
    postgresql ? false,
    aliases ? [],
    live ? true
  }: let
    home = "/home/${username}";
    documentRoot = "${home}/public_html";
    phpSocket = config.services.phpfpm.pools.${username}.socket;
  in lib.mkMerge [
    {
      users.groups.${username} = {};
      users.users.${username} = {
        inherit home;
        description = "Domain user for ${domain} managed by NixOS";
        group = username;
        isNormalUser = true;
        useDefaultShell = true;
        createHome = true;
        homeMode = "750";
        # See ../msmtp.nix
        extraGroups = [ "sendmail" ];
      };

      # So that apache can read the site.
      users.users.${httpdUser}.extraGroups = [ username ];

      networking.hosts."127.0.0.1" = [ domain "www.${domain}" ] ++ aliases;

      # Disable LetsEncrypt on non-live sites
      security.acme.certs."${domain}".server = lib.mkIf (!live) "https://acme-staging-v02.api.letsencrypt.org/directory";

      # Following:
      # https://wordpress.org/support/article/hardening-wordpress/#securing-wp-config-php
      # HTTP Authorization header is to ensure Apache forwards it to PHP
      services.httpd.virtualHosts."${domain}" = {
        inherit documentRoot;
        serverAliases = [ "www.${domain}" ] ++ aliases;
        onlySSL = true;
        enableACME = true;
        extraConfig = ''
          <Directory "${documentRoot}">
            Require all granted
            Options +FollowSymLinks +MultiViews -Indexes
            AllowOverride All

            ${lib.optionalString php ''
              <FilesMatch \.php\d*$>
                <If "-f %{REQUEST_FILENAME}">
                  SetHandler "proxy:unix:${phpSocket}|fcgi://localhost/"
                </If>
              </FilesMatch>
            ''}
          RewriteEngine on
          RewriteBase /
          RewriteRule ^index\.php$ - [L]
          RewriteCond %{REQUEST_FILENAME} !-f
          RewriteCond %{REQUEST_FILENAME} !-d
          RewriteRule . /index.php [L]
          </Directory>

          <Files wp-config.php>
            Require all denied
          </Files>

          <Files secret-keys.php>
            Require all denied
          </Files>

          ${rewriteRules primaryDomain}
        '';
      };
    }
    (lib.mkIf php (phpConfig { inherit username domain home; }))
    (lib.mkIf (php && mysql) (mysqlConfig { inherit username; }))
    (lib.mkIf (php && postgresql) (postgresqlConfig { inherit username; }))
    (lib.mkIf (wordpress) { vcc.wordpressSites.${username} = domain; })
  ];

  mkHeldDomain = { domain, aliases ? [] }: {
    services.httpd.virtualHosts."${domain}" = {
      documentRoot = "/home/_held/public_html";
      serverAliases = [ "www.${domain}" ] ++ aliases;
      onlySSL = true;
      enableACME = true;
    };
  };
}
