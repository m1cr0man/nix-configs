{ config, pkgs, ... }:
let
  backup_dest = "root@192.168.14.1:/zhuge2/zstorage/pc_backups/bgrs/";
in {

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
      ./services/httpd.nix
      ./services/mysql.nix
      ./services/postgresql.nix
    ];

  system.stateVersion = "21.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "ed241724";
    hostName = "bgrs";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.137.5";
      prefixLength = 24;
    }];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAjcQS+kqhAZ9EXs2wHArqWYIMh1snadkhpuz6fDIbeE9dTtr7Z1MfO5UsDAO/PpK/kyBU3pHBCpVpd9l/Vcxaf+f9pVONxpywcC00iDeZ7zdnKNr2ER9stG0Yo2es2CGt+2UPdjFOTqJsGiroNlKNi43voSuzIEKmNoord69AfUxAMXak0DeE5GjdKpmxvF5Volaa2wH2Kg/ZMiHT7KUQlxOnoemzz5/bAj2d2KLqD9bgfk0BWM29IHcVv+BUJ7FMuSq31d4022ABP/18mcFGIbGSRwvmbRf1lSWig1FjfA7UMcmEP5+22GXEqU6j99D2EVoX69qxP1XYwYCTCXnMVw== rsa-key-zeus-pc"
  ];

  systemd.services.copy-backups = let
    source_paths = "/var/lib/mysql_backup/*.zip /var/lib/postgresql_backup/*.zip";
  in {
    description = "Copy backups before shutdown";
    wantedBy = [ "mysql-backup.service" "postgresql-backup.service" ];
    before = [ "mysql-backup.service" "postgresql-backup.service" ];
    after = [ "network.target" ];
    path = with pkgs; [ rsync openssh ];
    script = "true";
    preStop = ''
      mkdir -p /var/www/backups/
      chown wwwrun:wwwrun /var/www/backups
      cd /var/www/backups
      for src in ${source_paths}; do
        if [ -e "$src" ]; then
          chown wwwrun:wwwrun "$src"
          mv "$src" .
        fi
      done
      rsync \
        -e "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5" \
        --chown='lucas:users' \
        --chmod=F660 \
        -va --delete \
        . '${backup_dest}' || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
