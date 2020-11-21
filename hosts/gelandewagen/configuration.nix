{ config, pkgs, ... }:
let
  secrets = import ../../common/secrets.nix;
in {

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../services/dns
      ../../services/ssh.nix
      ../../services/httpd.nix
      ../../services/gamesvm.nix
      #../../services/minecraft.nix
      ../../services/m1cr0blog.nix
      ../../services/minio.nix
      ../../services/openttd.nix
      ../../services/breogan.nix
      ../../services/plex.nix
      ../../services/weechat.nix
      ../../services/rb-tunnel.nix
      ../../services/tick
      ../../services/vault.nix
      ../../containers/mcwesty.nix
      ../../containers/mcaaron.nix
    ];

  system.stateVersion = "20.03";
  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };

  networking = {
    hostId = "4cdf6f98";
    hostName = "gelandewagen";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "144.76.44.123";
      prefixLength = 27;
    }];
    defaultGateway = "144.76.44.97";
    nameservers = [ "213.133.98.98" "1.1.1.1" ];
    hosts."136.206.15.3" = [ "irc.redbrick.dcu.ie" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.listenOptions = [ "/var/run/docker.sock" "0.0.0.0:2375" ];

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

  users.users.portfwd-guest = {
    home = "/var/empty";
    shell = pkgs.bashInteractive;
    group = "nogroup";
    hashedPassword = secrets.portfwd_guest_password;
    createHome = false;
    useDefaultShell = false;
  };


  users.users.breogan = {
    home = "/home/breogan";
    shell = pkgs.bashInteractive;
    group = "breogan";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIeiNkZ53utCm/d9a/m46xe00OTlRnRlrgEoiRmpW1j ed25519-key-20200418"
    ];
  };
  users.groups.breogan = {};

  # Enable KSM because the MC servers share a lot of data
  hardware.ksm.enable = true;

  networking.firewall.allowedTCPPorts = [ 27015 26900 1802 ];
  networking.firewall.allowedUDPPorts = [ 26900 26901 26902 27005 27015 27020 ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
}
