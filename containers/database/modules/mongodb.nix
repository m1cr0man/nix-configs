{ pkgs, lib, ... }:
let
  socket = "/run/mongodb/mongodb.sock";
in {
  services.mongodb = {
    enable = true;
    bind_ip = socket;
  };

  environment.systemPackages = [ pkgs.mongodb-tools ];

  systemd.services.mongodb = {
    # Required so that the service shuts down when no connections remain
    bindsTo = [ "mongodb-proxy.service" ];
    # Required so that the service does not auto-start on boot
    wantedBy = lib.mkForce [];
    serviceConfig = {
      Group = "mongodb";
      RuntimeDirectory = "mongodb";
    };
  };

  systemd.services."mongodb-proxy" = {
    description = "Connects clients to mongodb via systemd sockets";

    # Derived from https://www.man7.org/linux/man-pages/man8/systemd-socket-proxyd.8.html#EXAMPLES
    # bindsTo used so that if the socket unit is stopped, so is this.
    bindsTo = [ "mongodb-proxy.socket" ];
    # Required to start mongodb. Can't use bindsTo because we used it in mongodb (circular ref).
    requires = [ "mongodb.service" ];
    # Both the socket and the service need to be online before the proxy begins
    after = [ "mongodb-proxy.socket" "mongodb.service" ];

    unitConfig.JoinsNamespaceOf = "mongodb.service";

    serviceConfig = {
      ExecStart = "${pkgs.systemd.out}/lib/systemd/systemd-socket-proxyd --exit-idle-time=1min ${socket}";
      Type = "notify";
      User = "mongodb";
      Group = "mongodb";
    };
  };
  
  systemd.sockets."mongodb-proxy" = {
    description = "Socket unit for MongoDB Proxy";
    wantedBy = [ "sockets.target" ];

    listenStreams = [ "/var/lib/sockets/mongodb.sock" ];

    socketConfig = {
      # One proxy service per listener connection
      Accept = false;
      SocketUser = "mongodb";
      SocketGroup = "sockets";
      SocketMode = "0660";
      DirectoryMode = "0770";
    };
  };
}
