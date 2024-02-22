{ pkgs, lib, config, ... }:
let
  name = config.networking.hostName;
  domain = config.networking.domain;
in
{
  system.stateVersion = "24.05";

  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
    ];

  microvm.interfaces = [{
    type = "tap";
    id = "vm-kube-master";
    mac = "12:34:56:00:00:01";
  }];

  microvm.volumes = [{
    label = "lib";
    size = 13000;
    mountPoint = "/var/lib";
    image = "var-lib.img";
  }];

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = ["192.168.32.2/24" "fd12:3456:789a::2/64"];
      Gateway = "192.168.32.1";
      DNS = ["185.12.64.1" "1.1.1.1" "8.8.8.8"];
      IPv6AcceptRA = true;
      DHCP = "no";
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    llmnr = "true";
    extraConfig = ''
      MulticastDNS=true
    '';
    fallbackDns = [ "185.12.64.1" "1.1.1.1" ];
  };

  environment.systemPackages = with pkgs; [
    k3s
    k9s
    # kubernetes-helm
  ];

  services.k3s = {
    enable = true;
    role = "server";
    # Private server. Fite me.
    token = "e4fade69c4791b1942c4af720730bd499a72dfcf2143d41321f7db19e644f33d";
    clusterInit = true;
  };

  boot.supportedFilesystems = [ "overlayfs" ];

  # services.flannel.iface = "enp0s5";
  networking.firewall.trustedInterfaces = [ "docker0" "flannel.1" "cni0" "veth+" ];

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [
    53
    443
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    53
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
}
