{ config, lib, ... }:
let
  homeShares = lib.optionalAttrs (config.m1cr0man.samba-home-shares) {
    homes = {
      comment = "Your personal folder";
      "valid users" = "%S, %D%w%S";
      "force group" = "%G";
      "browseable" = "no";
      "inherit acls" = "yes";
      "create mask" = "0700";
      "directory mask" = "0700";
      "force create mode" = "0700";
      "force directory mode" = "0700";
    };
  };

  customShares = lib.mapAttrs
    (name: conf: {
      path = conf.path;
      comment = conf.comment;
      "valid users" = "@users";
      "guest ok" = "yes";
      "browseable" = "yes";
      "writeable" = "yes";
    } // conf.extraConfig)
    config.m1cr0man.samba-shares;
in
{
  imports = [
    ./options.nix
  ];

  services.samba = {
    enable = true;
    settings = lib.mkMerge [
      homeShares
      customShares
      {
        global = {
          "log file" = "/var/log/samba/log.%m";
          "log level" = "2";
          "max log size" = "50";

          "hosts allow" = "192.168. 100.64.48. 127.0.0.1 ::1";
          "hosts deny" = "all";
          "max connections" = "0";

          "netbios name" = lib.toUpper config.networking.hostName;
          "workgroup" = "WORKGROUP";
          "server string" = "NixOS File Server";

          "domain master" = "no";
          "preferred master" = "yes";
          "os level" = "4";
          "auto services" = "global";
          "server role" = "standalone";
          "wins support" = "no";
          "dns proxy" = "no";
          "hostname lookups" = "no";
          "name resolve order" = "lmhosts wins bcast host";

          "passdb backend" = "tdbsam";
          "client use spnego" = "no";
          "max protocol" = "SMB3_11";
          "min protocol" = "NT1";

          "getwd cache" = "yes";
          "strict sync" = "no";
          "strict locking" = "no";
          "sync always" = "no";

          "min receivefile size" = "16384";
          "use sendfile" = "yes";
          "aio read size" = "16384";
          "aio write size" = "16384";

          "kernel oplocks" = "no";
          "kernel share modes" = "no";
          "posix locking" = "no";

          "load printers" = "no";
          "printable" = "no";
          "printing" = "bsd";
          "printcap name" = "/dev/null";
          "disable spoolss" = "yes";

          # Disable xattrs
          "ea support" = "no";
          "store dos attributes" = "no";
          "map archive" = "no";
          "map hidden" = "no";
          "map readonly" = "no";
          "map system" = "no";

          "create mask" = "0770";
          "directory mask" = "0770";
          "force create mode" = "0770";
          "force directory mode" = "0770";
          "writable" = "yes";
          "browseable" = "yes";
          "force group" = "users";
          "guest account" = "smbguest";

          "usershare path" = "/var/lib/samba/usershares";
          "usershare max shares" = "100";
          "usershare allow guests" = "yes";
          "usershare owner only" = "yes";
        };
      }
    ];
  };

  users.users.smbguest = {
    uid = 1099;
    isSystemUser = true;
    group = "users";
    description = "Guest account for samba connections";
  };

  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
