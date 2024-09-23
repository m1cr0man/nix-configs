{ config, pkgs, ... }:
let
  user = "ledgersmb";
  dbUser = "lsmb_dbadmin";
  uid = 2002;
  gid = 2002;
in
{
  users.users.${user} = {
    inherit uid;
    group = user;
    isSystemUser = true;
    home = "/var/empty";
    hashedPassword = "$6$R5s6R04LAQuRe/kQ$7I/9wIm8wjmIt/evFmyOxFK.5dFs.5hcKAC3P1wgilNQhYbf/qlPAZhust.jSJv.rS7f5HSG8O24c6Ih4kfNp/";
  };
  users.groups.${user} = {
    inherit gid;
  };

  networking.firewall.trustedInterfaces = [ "podman0" ];

  virtualisation = {
    podman.extraPackages = [ pkgs.zfsUnstable ];

    oci-containers = {
      backend = "podman";

      containers.oldphp = {
        user = with builtins; "${toString uid}:${toString gid}";
        image = "php-destates:5.6-apache";
        autoStart = true;
        volumes = ["/var/www/destates:/var/www/html"];
        ports = ["8002:8002"];
      };
    };

    containers.storage.settings.storage = {
      driver = "zfs";
      options.zfs = {
        fsname = "zroot/containers";
      };
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };
}
