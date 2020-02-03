{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.chronograf;

  envOptions = {
    HOST = cfg.host;
    PORT = cfg.port;
    BOLT_PATH = cfg.boltPath;
    CANNED_PATH = cfg.cannedPath;
    RESOURCES_PATH = cfg.resourcesPath;
    BASE_PATH = cfg.basePath;
    STATUS_FEED_URL = cfg.statusFeedUrl;
    REPORTING_DISABLED = cfg.reportingDisabled;
    LOG_LEVEL = cfg.logLevel;
    INFLUXDB_URL = cfg.influxdb.url;
    INFLUXDB_USERNAME = cfg.influxdb.username;
    INFLUXDB_PASSWORD = cfg.influxdb.password;
    KAPACITOR_URL = cfg.kapacitor.url;
    KAPACITOR_USERNAME = cfg.kapacitor.username;
    KAPACITOR_PASSWORD = cfg.kapacitor.password;
    TLS_CERTIFICATE = cfg.tls.certificate;
    TLS_PRIVATE_KEY = cfg.tls.privateKey;
    TOKEN_SECRET = cfg.auth.tokenSecret;
    AUTH_DURATION = cfg.auth.duration;
    PUBLIC_URL = cfg.auth.publicUrl;
    GH_CLIENT_ID = cfg.githubAuth.clientId;
    GH_CLIENT_SECRET = cfg.githubAuth.clientSecret;
    GH_ORGS = cfg.githubAuth.orgs;
    GOOGLE_CLIENT_ID = cfg.googleAuth.clientId;
    GOOGLE_CLIENT_SECRET = cfg.googleAuth.clientSecret;
    GOOGLE_DOMAINS = cfg.googleAuth.domains;
    AUTH0_DOMAIN = cfg.auth0Auth.domain;
    AUTH0_CLIENT_ID = cfg.auth0Auth.clientId;
    AUTH0_CLIENT_SECRET = cfg.auth0Auth.clientSecret;
    AUTH0_ORGS = cfg.auth0Auth.orgs;
    HEROKU_CLIENT_ID = cfg.herokuAuth.clientId;
    HEROKU_SECRET = cfg.herokuAuth.secret;
    HEROKU_ORGS = cfg.herokuAuth.orgs;
    GENERIC_NAME = cfg.genericAuth.name;
    GENERIC_CLIENT_ID = cfg.genericAuth.clientId;
    GENERIC_CLIENT_SECRET = cfg.genericAuth.clientSecret;
    GENERIC_SCOPES = cfg.genericAuth.scopes;
    GENERIC_DOMAINS = cfg.genericAuth.domains;
    GENERIC_AUTH_URL = cfg.genericAuth.authUrl;
    GENERIC_TOKEN_URL = cfg.genericAuth.tokenUrl;
    GENERIC_API_URL = cfg.genericAuth.apiUrl;
  };

in {
  options.services.chronograf = {

    enable = mkEnableOption "chronograf";

    package = mkOption {
      description = "Which chronograf derivation to use";
      default = pkgs.chronograf;
      defaultText = "pkgs.chronograf";
      type = types.package;
    };

    user = mkOption {
      description = "User account under which chronograf runs";
      default = "chronograf";
      type = types.str;
    };

    group = mkOption {
      description = "Group under which chronograf runs";
      default = "chronograf";
      type = types.str;
    };

    dataDir = mkOption {
      description = "Data directory for chronograf data files.";
      default = "/var/lib/chronograf";
      type = types.path;
    };

    host = mkOption {
      description = "The IP that the chronograf service listens on.";
      default = "0.0.0.0";
      type = types.str;
    };

    port = mkOption {
      description = "The port that the chronograf service listens on for insecure connections.";
      default = 8888;
      type = types.int;
    };

    boltPath = mkOption {
      description = "The file path to the BoltDB file.";
      default = "./chronograf-v1.db";
      type = types.str;
    };

    cannedPath = mkOption {
      description = "The path to the directory of canned dashboards files.";
      default = cfg.dataDir + "/canned";
      defaultText = "\$\{dataDir\}/canned";
      type = types.path;
    };

    resourcesPath = mkOption {
      description = "Path to directory of canned dashboards, sources, Kapacitor connections, and organizations.";
      default = cfg.dataDir + "/resources";
      defaultText = "\$\{dataDir\}/resources";
      type = types.path;
    };

    basePath = mkOption {
      description = "The URL path prefix under which all chronograf routes will be mounted.";
      default = null;
      type = types.nullOr types.path;
    };

    statusFeedUrl = mkOption {
      description = "URL of JSON feed to display as a news feed on the client Status page.";
      default = "https://www.influxdata.com/feed/json";
      type = types.str;
    };

    reportingDisabled = mkOption {
      description = "Disables reporting of usage statistics. Usage statistics reported once every 24 hours include: OS, arch, version, clusterId, and uptime.";
      default = false;
      type = types.bool;
    };

    logLevel = mkOption {
      description = "Set the logging level.";
      default = "info";
      type = types.enum [ "debug" "info" "error" ];
    };

    influxdb = {

      url = mkOption {
        description = "The location of your InfluxDB instance, including http://, IP address, and port.";
        default = "";
        example = "http://127.0.0.1:8086";
        type = types.str;
      };

      username = mkOption {
        description = "The username for your InfluxDB instance.";
        default = "";
        type = types.str;
      };

      password = mkOption {
        description = "The password for your InfluxDB instance.";
        default = "";
        type = types.str;
      };

    };

    kapacitor = {

      url = mkOption {
        description = "The location of your Kapacitor instance, including http://, IP address, and port.";
        default = "";
        example = "http://0.0.0.0:9092";
        type = types.str;
      };

      username = mkOption {
        description = "The username for your Kapacitor instance.";
        default = "";
        type = types.str;
      };

      password = mkOption {
        description = "The password for your Kapacitor instance.";
        default = "";
        type = types.str;
      };

    };

    tls = {

      certificate = mkOption {
        description = "The file path to PEM-encoded public key certificate.";
        default = null;
        type = types.nullOr types.path;
      };

      privateKey = mkOption {
        description = "The file path to private key associated with given certificate.";
        default = null;
        type = types.nullOr types.path;
      };

    };

    auth = {

      tokenSecret = mkOption {
        description = "The secret for signing tokens.";
        default = "";
        type = types.str;
      };

      duration = mkOption {
        description = "The total duration (in hours) of cookie life for authentication.";
        default = "720h";
        type = types.str;
      };

      publicUrl = mkOption {
        description = "The public URL required to access Chronograf using a web browser. For example, if you access Chronograf using the default URL, the public URL value would be http://localhost:8888. Required for Google OAuth 2.0 authentication. Used for Auth0 and some generic OAuth 2.0 authentication providers.";
        default = "";
        type = types.str;
      };

    };

    githubAuth = {

      clientId = mkOption {
        description = "The GitHub client ID value for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      clientSecret = mkOption {
        description = "The GitHub Client Secret value for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      orgs = mkOption {
        description = "[Optional] Specify a GitHub organization membership required for a user.";
        default = "";
        type = types.str;
      };

    };

    googleAuth = {

      clientId = mkOption {
        description = "The Google Client ID value required for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      clientSecret = mkOption {
        description = "The Google Client Secret value required for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      domains = mkOption {
        description = "[Optional] Restricts authorization to users from specified Google email domains.";
        default = "";
        type = types.str;
      };

    };

    auth0Auth = {

      domain = mkOption {
        description = "The subdomain of your Auth0 client; available on the configuration page for your Auth0 client.";
        default = "";
        example = "https://myauth0client.auth0.com";
        type = types.str;
      };

      clientId = mkOption {
        description = "The Auth0 Client ID value required for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      clientSecret = mkOption {
        description = "The Auth0 Client Secret value required for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      orgs = mkOption {
        description = "[Optional] The Auth0 organization membership required to access Chronograf. Organizations are set using an 'organization' key in the user's app_metadata. Lists are comma-separated and are only available when using environment variables.";
        default = "";
        type = types.str;
      };

    };

    herokuAuth = {

      clientId = mkOption {
        description = "The Heroku Client ID for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      secret = mkOption {
        description = "The Heroku Secret for OAuth 2.0 support.";
        default = "";
        type = types.str;
      };

      orgs = mkOption {
        description = "The Heroku organization memberships required for access to Chronograf. Lists are comma-separated.";
        default = "";
        type = types.str;
      };

    };

    genericAuth = {

      name = mkOption {
        description = "The generic OAuth 2.0 name presented on the login page.";
        default = "";
        type = types.str;
      };

      clientId = mkOption {
        description = "The generic OAuth 2.0 Client ID value. Can be used for a custom OAuth 2.0 service.";
        default = "";
        type = types.str;
      };

      clientSecret = mkOption {
        description = "The generic OAuth 2.0 Client Secret value.";
        default = "";
        type = types.str;
      };

      scopes = mkOption {
        description = "The scopes requested by provider of web client.";
        default = "user:email";
        type = types.str;
      };

      domains = mkOption {
        description = "The email domain required for user email addresses.";
        default = "";
        type = types.str;
      };

      authUrl = mkOption {
        description = "The authorization endpoint URL for the OAuth 2.0 provider.";
        default = "";
        type = types.str;
      };

      tokenUrl = mkOption {
        description = "The token endpoint URL for the OAuth 2.0 provider.";
        default = "";
        type = types.str;
      };

      apiUrl = mkOption {
        description = "The URL that returns OpenID UserInfo-compatible information.";
        default = "";
        type = types.str;
      };

    };

  };

  config = mkIf cfg.enable {

    # Add to system packages so admins can use chronoctl
    environment.systemPackages = [ cfg.package ];

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.cannedPath}' 0700 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.resourcesPath}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.chronograf = {
      description = "Chronograf Service Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = mapAttrs (k: v: toString v) envOptions;

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/chronograf";
      };
    };

    users.users.chronograf = mkIf (cfg.user == "chronograf") {
      uid = config.ids.uids.chronograf;
      description = "Influxdb daemon user";
    };

    users.groups.chronograf = mkIf (cfg.group == "chronograf") {
      gid = config.ids.gids.chronograf;
    };
  };
}
