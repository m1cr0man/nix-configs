{ pkgs, config, lib, ... }:
let
  socket = "/run/ferretdb/ferretdb.sock";
in {
  services.ferretdb = {
    enable = true;
    settings = {
      FERRETDB_HANDLER = "pg";
      FERRETDB_STATE_DIR = "-";
      FERRETDB_DEBUG_ADDR = "-";
      FERRETDB_POSTGRESQL_URL = "postgres:///ferretdb?host=/var/lib/sockets";
      FERRETDB_LISTEN_ADDR = "";
      FERRETDB_LISTEN_UNIX = socket;
    };
  };

  # Use domain socket [eer auth.
  # User is created in ./postgresql.nix
  systemd.services.ferretdb = {
    # Required so that the service shuts down when no connections remain
    bindsTo = [ "ferretdb-proxy.service" ];
    # Required so that the service does not auto-start on boot
    wantedBy = lib.mkForce [];

    serviceConfig = {
      DynamicUser = lib.mkForce false;
      RuntimeDirectory = "ferretdb";
      User = "ferretdb";
      Group = "sockets";
      # Workaround for FERRETDB_LISTEN_ADDR="" ineffective
      ExecStart = lib.mkForce "${config.services.ferretdb.package}/bin/ferretdb --listen-addr=";
    };
  };

  environment.systemPackages = [ pkgs.mongodb-tools ];

  systemd.services."ferretdb-proxy" = {
    description = "Connects clients to FerretDB via systemd sockets";

    # Derived from https://www.man7.org/linux/man-pages/man8/systemd-socket-proxyd.8.html#EXAMPLES
    # bindsTo used so that if the socket unit is stopped, so is this.
    bindsTo = [ "ferretdb-proxy.socket" ];
    # Required to start ferretdb. Can't use bindsTo because we used it in ferretdb (circular ref).
    requires = [ "ferretdb.service" ];
    # Both the socket and the service need to be online before the proxy begins
    after = [ "ferretdb-proxy.socket" "ferretdb.service" ];

    unitConfig.JoinsNamespaceOf = "ferretdb.service";

    serviceConfig = {
      ExecStart = "${pkgs.systemd.out}/lib/systemd/systemd-socket-proxyd --exit-idle-time=1min ${socket}";
      Type = "notify";
      User = "ferretdb";
      Group = "sockets";
    };
  };

  # Connection URL: mongodb://%2Fvar%2Flib%2Fsockets%2Fmongodb.sock
  # Yes, URL encoded paths. Lol.
  systemd.sockets."ferretdb-proxy" = {
    description = "Socket unit for FerretDB Proxy";
    wantedBy = [ "sockets.target" ];

    listenStreams = [ "/var/lib/sockets/mongodb.sock" ];

    socketConfig = {
      # One proxy service per listener connection
      Accept = false;
      SocketUser = "ferretdb";
      SocketGroup = "sockets";
      SocketMode = "0660";
      DirectoryMode = "0770";
    };
  };
}
