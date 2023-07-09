{ config, pkgs, lib, ... }:
let
  backup_dest = "root@192.168.14.1:/zhuge2/zstorage/pc_backups/bgrs/";
  local_backup_dest = "/zeuspc/Backups/BGRS";
in
{

  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "monitoring"
      "www/httpd.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  m1cr0man.webserver.setupACME = false;

  system.stateVersion = "23.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;

  networking = {
    hostId = "ed241724";
    hostName = "bgrs";
    useDHCP = false;

    defaultGateway = "192.168.14.254";
    usePredictableInterfaceNames = false;

    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.137.5";
      prefixLength = 24;
    }];
    interfaces.eth1.ipv4.addresses = [{
      address = "192.168.14.4";
      prefixLength = 24;
    }];
    nameservers = [ "192.168.14.254" "1.1.1.1" ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
  ];

  systemd.services.copy-backups =
    let
      source_paths = "/var/lib/mysql_backup/*.zip /var/lib/postgresql_backup/*.zip";
    in
    {
      description = "Copy backups before shutdown";
      wantedBy = [ "mysql-backup.service" "postgresql-backup.service" ];
      before = [ "mysql-backup.service" "postgresql-backup.service" ];
      after = [ "network.target" "zeuspc.mount" ];
      wants = [ "zeuspc.mount" ];
      path = with pkgs; [ rsync openssh util-linux ];
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
          -e "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i /root/.ssh/id_ed25519" \
          --chown='lucas:users' \
          --chmod=F660 \
          -va --delete \
          . '${backup_dest}' || true

        if mountpoint /zeuspc; then
          rsync \
            -va --delete \
            . '${local_backup_dest}' || true
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
}
