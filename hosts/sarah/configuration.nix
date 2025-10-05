{ config, pkgs, lib, ... }:
{
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
      "servers/samba"
      "www/tailscale.nix"
    ]
    ++
    addModulesRecursive ./modules
    ++ [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "25.11";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.network.enable = lib.mkForce false;

  # Reduce auto snapshot frequency
  services.zfs.autoSnapshot.frequent = lib.mkForce 0;

  # Need more build tmpfile space
  services.logind.settings.Login.RuntimeDirectorySize = "2G";
  systemd.services.nix-daemon.environment.TMPDIR = "/nix/tmp";

  networking = {
    hostId = "a5206bac";
    hostName = "sarah";
    useDHCP = false;
    useNetworkd = true;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.137.2";
      prefixLength = 24;
    }];
    interfaces.eth1.ipv4.addresses = [{
      address = "192.168.14.3";
      prefixLength = 24;
    }];
    defaultGateway = {
      interface = "eth1";
      address = "192.168.14.254";
    };
    nameservers = [ "192.168.14.254" "1.1.1.1" ];

    firewall.allowedTCPPorts = [ 8086 8030 ];
    # Loopback interface
    firewall.trustedInterfaces = [ "eth0" ];
  };

  # Workaround for systemd-networkd-wait-online.service failures
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    ""
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any --timeout=30"
  ];

  # Fix for routing issues
  m1cr0man.tailscale.enableLocalRoutingPatch = true;

  # Enable VSCode Remote Server
  services.vscode-server.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ/+dK+9Y/QduSpNPoX/yfKYZazgUVwhs3DjH008U2C root@bgrs"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
  ];
}
