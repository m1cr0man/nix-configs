{ config, pkgs, ... }:
{
  # Create a user for socket based auth
  # TODO might have to set uid to 1042 or something so it can be added to db container
  users.users.openspy = {
    uid = 1000;
    isSystemUser = true;
    group = "openspy";
    home = config.m1cr0man.container.stateDir;
    extraGroups = [ "podman" "redis-openspy" "sockets" config.services.mysql.group ];
    homeMode = "775";
  };
  users.groups.openspy = {
    gid = 1000;
  };

  environment.systemPackages = [ pkgs.rabbitmqadmin-ng ];

  # Socket is /run/mysqld/mysqld.sock
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "${config.m1cr0man.container.stateDir}/mysql";
    ensureUsers = [{
      name = "openspy";
      ensurePermissions = {
        "*.*" = "ALL PRIVILEGES";
      };
    }];
    ensureDatabases = [
      "Gamemaster"
      "GameTracker"
      "KeyMaster"
      "Peerchat"
    ];
  };

  # Socket is /run/redis-openspy/redis.sock
  services.redis.servers.openspy = {
    enable = true;
    # dataDir = "${config.m1cr0man.container.stateDir}/redis";
    user = "openspy";
    port = 6379;
    bind = "0.0.0.0";
    settings.protected-mode = "no";
  };

  # No unix socket, TCP port 5672
  services.rabbitmq = {
    enable = true;
    dataDir = "${config.m1cr0man.container.stateDir}/rabbitmq";
    listenAddress = "0.0.0.0";
    managementPlugin.enable = true;
  };
}
