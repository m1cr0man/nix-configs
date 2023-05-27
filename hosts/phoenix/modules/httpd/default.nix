{ config, lib, pkgs, ... }:
let
  tld = "vccomputers.ie";
  adminAddr = "webmaster@${tld}";
  acmeRoot = "/var/lib/acme/acme-challenge";
  php = pkgs.php82.buildEnv {
    extensions = { enabled, all }: enabled ++ (with all; [
      imagick
      curl
      dom
      exif
      mbstring
      openssl
      xml
      zip
      filter
      iconv
      intl
      sockets
    ]);
    extraConfig = ''
      memory_limit = 256M
      sendmail_path = "${pkgs.msmtp}/bin/msmtp -C /etc/msmtprc -t"
      mail.add_x_header = true
    '';
  };
  wp-cli = pkgs.wp-cli.override { inherit php; };
  wpTheme = "twentytwentythree";
in {
  imports = [ ./domains.nix ./options.nix ];

  environment.systemPackages = [ wp-cli ];

  services.phpfpm = {
    phpPackage = php;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = config.m1cr0man.adminEmail;
      webroot = acmeRoot;
    };
  };

  services.httpd = {
    inherit adminAddr;

    enable = true;
    mpm = "event";
    maxClients = 500;
    logFormat = "combinedplus";
    extraModules = [ "proxy_wstunnel" "proxy_fcgi" ];

    extraConfig = ''
      ServerSignature off
      ServerTokens Prod

      ProxyRequests off
      ProxyVia Off
      ProxyPreserveHost On

      <IfModule mod_ssl.c>
        SSLSessionTickets off
        SSLUseStapling On
        SSLStaplingCache "shmcb:/run/httpd/ssl_stapling(32768)"
      </IfModule>

      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"  \"%{reqenv:SCRIPT_NAME}i\" %v" combinedplus

      DirectoryIndex index.php index.html index.htm index.shtml
    '';

    virtualHosts = {
      # Only acme certs and status are accessible via port 80,
      # everything else is explicitly upgraded to https
      "acme.${tld}" = {
        inherit adminAddr;
        serverAliases = ["*"];
        useACMEHost = tld;
        # forceSSL but don't actually listen SSL, so that this vhost
        # operates as a global redirector.
        forceSSL = true;
        listen = [{ ip = "*"; port = 80; ssl = false; }];
        locations = {
          # Server status
          "/.server-status".extraConfig = ''
            SetHandler server-status
            <RequireAny>
              Require ip 127.0.0.1
            </RequireAny>
          '';
        };
      };
    };
  };

  systemd.services = lib.mkIf (config.vcc.wordpressSites != {}) {
    wordpress-setup = let
      secretsVars = [ "AUTH_KEY" "SECURE_AUTH_KEY" "LOGGED_IN_KEY" "NONCE_KEY" "AUTH_SALT" "SECURE_AUTH_SALT" "LOGGED_IN_SALT" "NONCE_SALT" ];
      # GENUSERNAME replaced by sed in service script
      wpConfigBase = pkgs.writeTextFile {
        name = "wp-config.php";
        text = ''
          <?php
            $table_prefix = 'wp_';

            define('DB_HOST', "localhost:/run/mysqld/mysqld.sock");
            define('DB_NAME', 'GENUSERNAME');
            define('DB_USER', 'GENUSERNAME');
            // UNIX socket auth, no password necessary.
            define('DB_PASSWORD', "");
            define('DB_CHARSET', 'utf8mb4');
            define('DB_COLLATE', "utf8mb4_unicode_520_ci");
            define('FORCE_SSL_ADMIN', true);
            define('DISABLE_WP_CRON', true);
            $_SERVER['HTTPS'] = 'on';

            // The following lines are acquired from the vendored wp-config.php
            if ( !defined('ABSPATH') )
              define('ABSPATH', dirname(__FILE__) . '/');

            require_once(ABSPATH . 'secret-keys.php');

            require_once(ABSPATH . 'wp-settings.php');
          ?>
        '';
        checkPhase = "${php}/bin/php --syntax-check $target";
      };
    in {
      description = "Create wordpress configuration data for new users";
      # Concat username + domain with a colon between
      # so that we can iterate in bash.
      scriptArgs = builtins.concatStringsSep " " (
        lib.mapAttrsToList
          (username: domain: "${username}:${domain}")
        config.vcc.wordpressSites
      );
      path = [ wp-cli pkgs.bash pkgs.su pkgs.which ];
      after = [ "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        WorkingDirectory = "/home";
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        for site in "$@"; do
          username="$(echo "$site" | cut -d: -f1)"
          domain="$(echo "$site" | cut -d: -f2)"
          docroot="/home/$username/public_html"
          new=0
          sucmd="su -s $(which bash) $username -c"

          if [ ! -f "$docroot/index.php" -a ! -f "$docroot/index.html" ]; then
            echo Installing Wordpress for $username
            new=1

            # && $(which wp) core download --locale=en_GB --path='$docroot' \
            $sucmd "\
              mkdir -p '$docroot/wp-content/themes' \
              && cp -rL '${pkgs.wordpress}/share/wordpress/.' '$docroot/' \
              && cp -rL '${pkgs.wordpressPackages.themes.${wpTheme}}' '$docroot/wp-content/themes/${wpTheme}' \
              && rm -f '$docroot/wp-config.php' \
              && chmod -R u=rwX,g=rX,o= '$docroot' \
            "
          fi

          secrets="$docroot/secret-keys.php"
          if [[ ! -f "$secrets" ]]; then
            echo Creating $secrets

            echo '<?php' > "$secrets"
            ${lib.concatMapStringsSep "\n" (var: ''
              echo "define('${var}', '$(tr -dc a-zA-Z0-9 </dev/urandom 2>/dev/null | head -c 64)');" >> "$secrets"
            '') secretsVars}
            echo '?>' >> "$secrets"

            chmod 400 "$secrets"
            chown -R "$username:$username" "$secrets"
          fi

          wp_config="$docroot/wp-config.php"
          if [[ ! -f "$wp_config" ]]; then
            echo Creating $wp_config

            sed "s/GENUSERNAME/$username/g" '${wpConfigBase}' > "$wp_config"

            if [[ "$new" -gt 0 ]]; then
              echo Performing install
              pwfile="/home/$username/wp-admin-creds.txt"
              touch "$pwfile"
              chmod 400 "$pwfile"
              pw="$(tr -dc a-zA-Z0-9 </dev/urandom 2>/dev/null | head -c 16)"
              echo Username "admin_$username" Password "$pw" > "$pwfile"
              chown -R "$username:$username" "$pwfile"

              cd "$docroot"
              $sucmd "$(which wp) core install \
                --url='$domain' \
                --title='$domain' \
                --admin_user='admin_$username' \
                --admin_password='$pw' \
                --admin_email='webmaster+wp+$username@${tld}'"
            fi

            chmod 400 "$wp_config"
            chown -R "$username:$username" "$docroot"
          fi
        done
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
