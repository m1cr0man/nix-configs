{ config, pkgs, ... }:
{

  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
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
      ../../services/conor.nix
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
    interfaces.eth0.ipv6.addresses = [{
      address = "2a01:4f8:191:503f::1";
      prefixLength = 64;
    }];
    defaultGateway = "144.76.44.97";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    nameservers = [ "213.133.98.98" "1.1.1.1" ];
    hosts."136.206.15.3" = [ "irc.redbrick.dcu.ie" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.listenOptions = [ "/var/run/docker.sock" "0.0.0.0:2375" ];

  systemd.services.stress = {
    description = "CPU stress to stop crashes";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.stress}/bin/stress --cpu 2
    '';
    serviceConfig = {
      Restart = "always";
      CPUWeight = 5;
      CPUSchedulingPriority = 2;
    };
  };

  networking.firewall.allowedTCPPorts = [ 27015 27016 26900 1802 7776 7777 ];
  networking.firewall.allowedUDPPorts = [ 26900 26901 26902 27005 27015 27016 27020 7776 7777 ];
}
