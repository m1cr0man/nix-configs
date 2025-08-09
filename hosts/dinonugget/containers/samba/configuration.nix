{ config, lib, pkgs, self, ... }:
let
  port = num: protocol: { hostPort = num; containerPort = num; inherit protocol; };
in
{
  systemd.services.zhuge2-autoimport = {
    description = "Automatically imports zhuge2 if it is not imported already";
    wantedBy = [ "multi-user.target" ];
    requires = [ "local-fs.target" ];
    after = [ "local-fs.target" ];
    # Auto start the container after import
    before = [ "systemd-nspawn@samba.service" ];
    wants = [ "systemd-nspawn@samba.service" ];
    path = [ pkgs.gnugrep pkgs.zfsUnstable ];
    unitConfig.ConditionPathIsMountPoint = "!/zhuge2";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo Waiting for pool to appear
      while true; do
        if zpool import | grep zhuge2; then
          zpool import zhuge2
          exit 0
        fi
        sleep 5
      done
    '';
  };

  systemd.services."systemd-nspawn@samba".unitConfig.RequiresMountsFor = "/zhuge2";

  nixos.containers.instances.samba = {
    activation.autoStart = false;
    ephemeral = true;
    userNamespacing = false;
    bridge = "br-containers";

    bindMounts = [
      "/zhuge2:/zhuge2"
      "/nix/persist/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key"
    ];

    forwardPorts = [
      (port 139 "tcp")
      (port 445 "tcp")
      (port 137 "udp")
      (port 138 "udp")
    ];

    system-config = {
      system.stateVersion = config.system.stateVersion;
      _module.args.self = self;
      m1cr0man.instanceType = "container";
      networking.hostName = "samba";
      networking.domain = config.networking.domain;

      imports = with lib.m1cr0man.module;
        addModules ../../../../modules [
          "global-options.nix"
          "sysconfig/core.nix"
          "sysconfig/users-groups.nix"
          "secrets"
          "servers/samba"
        ]
        ++
        addModulesRecursive ./modules
        ++ [
          self.inputs.sops-nix.nixosModules.sops
        ];
    };
  };
}
