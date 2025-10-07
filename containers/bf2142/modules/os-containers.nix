{ config, pkgs, ... }:
let
  geolite2 = builtins.fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb";
    sha256 = "0nn7rapnqbsg40wv97d9k6l5ivrh1czi0hi8lrz17hqlr4znb1j7";
  };
  stateDir = config.m1cr0man.openspy-containers.stateDir;
  rabbitmqEnv = "${stateDir}/rabbitmq.env";
  apiKeyEnv = "${stateDir}/openspy-api-key.env";
  mongodbURI = "mongodb:///var/lib/sockets/mongodb.sock";
  # The ancient version of NodeJS mongodb client (v3.7.4) requires a very
  # archaic socket address
  mongodbURINode = "mongodb://%2fvar%2flib%2fsockets%2fmongodb.sock";
  redisURI = "redis://host.containers.internal:6379/";

  # Core variables (not core-web)
  coreEnvironment = {
    OPENSPY_REDIS_ADDRESS = "host.containers.internal";
    OPENSPY_REDIS_PORT = "6379";
    OPENSPY_REDIS_SSL = "0";
    OPENSPY_REDIS_SSL_NO_VERIFY = "1";
    OPENSPY_AMQP_ADDRESS = "host.containers.internal";
    OPENSPY_AMQP_PORT = "5672";
    OPENSPY_WEBSERVICES_URL = "http://core-web:8080";
    OPENSPY_NATNEG_BIND_ADDR = "0.0.0.0";
    OPENSPY_NATNEG_BIND_PORT = "30695";
    OPENSPY_QR_BIND_ADDR = "0.0.0.0";
    OPENSPY_QR_BIND_PORT = "30694";
    OPENSPY_SBV1_BIND_ADDR = "0.0.0.0";
    OPENSPY_SBV1_BIND_PORT = "30692";
    OPENSPY_SBV2_BIND_ADDR = "0.0.0.0";
    OPENSPY_SBV2_BIND_PORT = "30693";
    OPENSPY_GP_BIND_ADDR = "0.0.0.0";
    OPENSPY_GP_BIND_PORT = "30974";
    OPENSPY_GSTATS_BIND_ADDR = "0.0.0.0";
    OPENSPY_GSTATS_BIND_PORT = "30836";
    OPENSPY_SM_BIND_ADDR = "0.0.0.0";
    OPENSPY_SM_BIND_PORT = "30734";
    OPENSPY_CDKEY_BIND_ADDR = "0.0.0.0";
    OPENSPY_CDKEY_BIND_PORT = "30694";
    OPENSPY_PEERCHAT_BIND_ADDR = "0.0.0.0";
    OPENSPY_PEERCHAT_BIND_PORT = "30838";
    # OPENSPY_UTMASTER_BIND_ADDR = "0.0.0.0";
    # OPENSPY_UTMASTER_BIND_PORT = "30839";
    # OPENSPY_UTMASTER_MAPPINGS_PATH = "utmaster.xml";
    # FIXME customize these
    # UTMASTER_MOTD_DATA = "VGhpcyBpcyB0aGUgdXRtYXN0ZXIgZGVmYXVsdCBkb2NrZXIgbW90ZA==";
    # UTMASTER_MOTD_COMMUNITY_DATA = "VGhpcyBpcyB0aGUgdXRtYXN0ZXIgZGVmYXVsdCBkb2NrZXIgY29tbXVuaXR5IG1vdGQ=";
    OPENSPY_FESL_TOS_PATH = builtins.toString (pkgs.writeTextFile {
      name = "fesl_tos.txt";
      text = "<body>OpenSpy local test</body>";
    });
    OPENSPY_SSL_CERT = builtins.toString "${stateDir}/openspy.local/cert.pem";
  };

  coreContainer = runFile: ports: {
    inherit ports;
    image = "chcniz/openspy-core:latest";
    volumes = [
      "${config.m1cr0man.container.stateDir}/core:/app-workdir"
    ];
    environment = coreEnvironment // {
      RUN_FILE = runFile;
    };
    environmentFiles = [
      rabbitmqEnv
      apiKeyEnv
    ];
  };

  webBackendContainer = image: {
    inherit image;
    ports = [ "8080:8080" ];
    environmentFiles = [
      "${stateDir}/openspy-auth-keys.env"
      rabbitmqEnv
    ];
    environment = {
      CONNECTIONSTRINGS__REDISCACHE = "host.containers.internal:6379,allowAdmin=true";
      CONNECTIONSTRINGS__GAMEMASTERDB = "server=/run/mysqld/mysqld.sock;database=Gamemaster;user=openspy";
      CONNECTIONSTRINGS__GAMETRACKERDB = "server=/run/mysqld/mysqld.sock;database=GameTracker;user=openspy";
      CONNECTIONSTRINGS__KEYMASTERDB = "server=/run/mysqld/mysqld.sock;database=KeyMaster;user=openspy";
      CONNECTIONSTRINGS__PEERCHATDB = "server=/run/mysqld/mysqld.sock;database=Peerchat;user=openspy";
      CONNECTIONSTRINGS__SNAPSHOTDB = mongodbURI;
      # _MUST_ be a "+" otherwise curl localhost on ipv6 will connection reset
      ASPNETCORE_URLS = "http://+:8080";
    };
  };
in {
  m1cr0man.openspy-containers.containers = {
    # Runs the main openspy service
    core-web = webBackendContainer "docker.io/chcniz/openspy-web-backend:latest";

    # Used only to generate the first admin API key
    core-web-unauthed = webBackendContainer "localhost/openspy-web-backend-unauthed:latest";

    # BEGIN "core"
    serverbrowsing = coreContainer "serverbrowsing" [
      "28900:30692"
      "28910:30693"
    ];

    qr = coreContainer "qr" [ "27900:30694/udp" ];

    natneg = coreContainer "natneg" [ "27901:30695/udp" ];

    GP = coreContainer "GP" [ "29900:30974" ];

    SM = coreContainer "SM" [ "29901:30734" ];

    gstats = coreContainer "gstats" [ "29920:30836" ];

    FESL-bf2142 = coreContainer "FESL" [ "18300:30837" ];

    peerchat = coreContainer "peerchat" [ "6667:30838" ];

    # TODO utmaster.xml
    # utmaster = coreContainer "utmaster" [ "28902:30839" ];
    # END "core"

    # BEGIN "compose" (services from the docker-compose in the compose repo)
    natneg-helper = {
      image = "chcniz/openspy-natneg-helper:latest";
      environmentFiles = [ rabbitmqEnv ];
      environment = {
        UNSOLICITED_PORT_PROBE_DRIVER = "0.0.0.0:30695";
        UNSOLICITED_IP_PROBE_DRIVER = "unset";
        UNSOLICITED_IPPORT_PROBE_DRIVER = "unset";
        SKIP_ERTL = "1";
      };
    };

    qr-service = {
      image = "chcniz/openspy-qr-service:latest";
      volumes = [
        "${toString geolite2}:/GeoLite2-City.mmdb"
      ];
      environmentFiles = [ rabbitmqEnv ];
      environment = {
        REDIS_URL = redisURI;
        GEOIP_DB_PATH = "/GeoLite2-City.mmdb";
      };
    };

    gamestats-web = {
      image = "chcniz/openspy-gamestats-web:latest";
      environment = {
        GAMESTATS_MONGODB_URI = mongodbURINode;
        PORT = "4000";
      };
      ports = [ "4000:4000/tcp" ];
    };

    stella-web = {
      image = "chcniz/openspy-bf2142-stella-web:latest";
      environmentFiles = [ apiKeyEnv ];
      environment = {
        API_ENDPOINT = "http://core-web:8080";
        # MONGODB_URI = mongodbURI;
        PORT = "4001";
      };
      ports = [ "4001:4001/tcp" ];
    };
    # END "compose"
  };
}
