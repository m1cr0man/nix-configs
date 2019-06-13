# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  imports =
    [
      ./hardware-configuration.nix
      ../../common/region.nix
      ../../services/dns
      ../../services/ssh.nix
      ../../services/httpd.nix
      ../../services/minecraft.nix
      ../../services/minio.nix
    ];

  system.stateVersion = "19.09";
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sdc";
  };
  boot.kernelParams = [
    "boot.shell_on_fail"
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = false;
    forceImportAll = false;
  };
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 1;
  };

  networking = {
    hostId = "4cdf6f98";
    hostName = "gelandewagen";
    domain = "m1cr0man.com";

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "144.76.44.123";
      prefixLength = 27;
    } {
      address = "144.76.44.62";
      prefixLength = 27;
    }];
    defaultGateway = "144.76.44.97";
    nameservers = [ "213.133.98.98" "1.1.1.1" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.listenOptions = [ "/var/run/docker.sock" "0.0.0.0:2375" ];
  environment.systemPackages = with pkgs; [
    wget vim git screen steamcmd
  ];

  users.users.gmod = {
    createHome = true;
    description = "Garrys mod";
    extraGroups = [ "wheel" ];
    group = "users";
    home = "/home/gmod";
    isSystemUser = false;
    useDefaultShell = true;
    uid = 1000;
  };

  networking.firewall.allowedTCPPorts = [ 25585 25595 80 27015 ];
  networking.firewall.allowedUDPPorts = [ 25585 25595 26901 27005 27015 27020 ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
}
