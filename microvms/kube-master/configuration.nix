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

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      Address = ["192.168.32.2/24" "fd12:3456:789a::2/64"];
      Gateway = "192.168.32.1";
      DNS = ["1.1.1.1"];
      IPv6AcceptRA = true;
      DHCP = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = ["master"];
    easyCerts = true;

    masterAddress = "${name}.${domain}";
    proxy.hostname = "${name}.${domain}";
    apiserver = {
      securePort = 443;
      advertiseAddress = "192.168.32.1";
    };
  };

  services.flannel.iface = "enp0s5";

  networking.firewall.allowedTCPPorts = [
    443
    10250
  ];
  networking.firewall.trustedInterfaces = [ "docker0" ];
}
