{ config, pkgs, lib, ... }:
let
  bridgeName = "br-containers";
in
{
  nixos.containers.enableAutostartService = false;
  environment.systemPackages = [ pkgs.nixos-nspawn pkgs.e2fsprogs ];

  # Configure a bridge interface which will be used for all containers
  # on this network.
  networking.firewall.trustedInterfaces = [ bridgeName "vb-+" ];
  networking.hosts."bee7::1" = [ "containerhost" "containerhost.local" ];
  m1cr0man.container.hostAddress = "bee7::1";
  services.radvd.enable = lib.mkForce false;


  networking.nat = {
    enableIPv6 = true;
    enable = true;
  };

  systemd.network = {
    netdevs."40-${bridgeName}".netdevConfig = {
      Name = bridgeName;
      Kind = "bridge";
    };
    networks."40-${bridgeName}" = {
      name = bridgeName;
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        Address = [ "192.168.27.1/24" "bee7::1/64" ];
        LinkLocalAddressing = "ipv6";
        IPMasquerade = "both";
        LLDP = true;
        EmitLLDP = "customer-bridge";
        DHCPServer = true;
        IPv6SendRA = true;
        IPv6AcceptRA = false;
      };
      ipv6Prefixes = [{
        Prefix = "bee7::/64";
      }];
    };
  };
}
