{ config, pkgs, ... }:
let
  secrets = import ../../common/secrets.nix;
in {

  imports =
    [
      ./hardware-configuration.nix
      ./mc-servers.nix
      ../../common/sysconfig.nix
      ../../services/dns
      ../../services/ssh.nix
      ../../services/eggnor.nix
      ../../services/acme.nix
      ../../services/httpd.nix
      ../../services/m1cr0blog.nix
      ../../services/matrix.nix
      ../../services/minio.nix
      ../../services/openttd.nix
      ../../services/postgresql.nix
      ../../services/breogan.nix
      ../../services/plex.nix
      ../../services/weechat.nix
      ../../services/tick
      ../../services/vault.nix
    ];

  system.stateVersion = "21.03";
  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };
  m1cr0man.zfs = {
    scrubStartTime = "*-*-* 07:00:00";
    scrubStopTime = "*-*-* 07:15:00";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    swapDevices = 0;
    numDevices = 2;
    memoryPercent = 12;
    memoryMax = 3072000000000;
  };

  networking = {
    hostId = "4cdf6f98";
    hostName = "gelandewagen";
    useDHCP = false;
    # hosts."127.0.0.1" = [ "m1cr0man.com" ];

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
    isNormalUser = true;
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
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtXDL7LWBiySe4YZmosFxqzjxjcROtmse22+HFShD4L7bjpqWDkIy7ynTAn/EzizVAT2UFs2z2QObJBsaxObPMdYLpAnVW2sLKh40AhsveYlxiXhVbpfMqIZ6lqtUOMqSN3ql7eUwqWMnWtBz4yl5XwLIoNmnT20XDjNJzoGk+VOTNedldDZEM1oHOw+owtAr1k2sBu2dStXbiUgIjAyDOszNp5z1dyV8Zu/bEmFj3+Uw/JID+IneZCtk/HKrPldwv+tAbSnL2+LTmQhcdfk3GZGRh/EcAyHB+PkswIoxP7p7XoQLt10fdYYpzPur4Mo45gH/RE9ybhpxfasAj7411w== git@ip"
    ];
  };

  users.users.breogan = {
    home = "/home/breogan";
    shell = pkgs.bashInteractive;
    group = "breogan";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIeiNkZ53utCm/d9a/m46xe00OTlRnRlrgEoiRmpW1j ed25519-key-20200418"
    ];
  };
  users.groups.breogan = {};

  users.users.anders = {
    home = "/home/anders";
    shell = pkgs.bashInteractive;
    group = "anders";
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuW9Vc1zz3qA++TpqLb6jTBx2ZfejO0uqrYt/tmGaEM ed25519-key-20210126"
    ];
  };
  users.groups.anders = {};

  users.users.mcadmins = {
    home = "/home/mcadmins";
    shell = pkgs.bashInteractive;
    group = "mcadmins";
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys ++ [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMTwoP357Z13kPk3jRc8fzSCQCIYrIe/X/a4rtKq/sPE+6ydUsXXZdcB9PvFNElDmTJGk0IoaJ6gjfjJFhzRMJvg4IKJ3mFWnkJ2FBdn+rB9CWxzx8VRZfN5Tj3BmQ/olgvxHlyI+Qh1+ceBCUH1PzNhAXTJ8uSc1rIWspunbbOU3kjW7nkf3SYCRIdHkFZXr3sf7jhw0EVvFUqfWMEl3uiEbFXzd3Hq1rFxAhvf0145ydnH/gBUyxuTP4tQDSbB3yfs8wSTRhXVDqYVz6+BKdRk67SsdY50+GR1Vp2Pd/tdmJlhu7yYyn6IPY8LIx3SGWPlk5prckDvA3I4ppdIz0ZcSgqgi9fYDmDWisaWwjPJzGlTUHLnzgxehCqrwj0qQC+k5PS6Epxq1OCyBlJcSUGgCQypLZMEOuqqf5G6ouhpvzBoDOc131Ih5Rj0zH/5r+ke+GGifoLRtbHBf2TdFjnNGjlf2XANLwHhICs3r7CPr6Kd+uQZzzApCB+wx1m8hBtax86/XqZUOr70tbbUiZvZpWzJMo7jsozsUnWfN4NBqzsyZ6/nWzpCYSXxiG8xGIptFBHr/2EsY3QaoJ8ncXdEt5d1WgqxQ3cepW+n+KYcavymy2ywO1Mij2Dwt7SobUMhkcrfVcxyFehozQAOZkZqL3ByGAaqdghpkIwn0MCQ== sailslickcode"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9ajmos3wSH3igGDzNXTC8Gpew2XfFWE17czqXXJMBs dvxl@synckey-apd"
    ];
  };
  users.groups.mcadmins = {};

  users.users.lucas = {
    home = "/home/lucas";
    shell = pkgs.bashInteractive;
    group = "lucas";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };
  users.groups.lucas = {};

  systemd.services.stress = {
    description = "CPU stress to stop crashes";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.stress}/bin/stress --cpu 2
    '';
    serviceConfig = {
      Restart = "always";
      CPUWeight = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ 27015 27016 26900 1802 7776 7777 ];
  networking.firewall.allowedUDPPorts = [ 26900 26901 26902 27005 27015 27016 27020 7776 7777 ];
}
