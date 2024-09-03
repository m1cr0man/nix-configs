{ config, pkgs, lib, ... }:
let
  bridgeName = "br-containers";
in
{
  # Configure a bridge interface which will be used for all containers
  # on this network.
  networking.firewall.trustedInterfaces = [ bridgeName "ve-+" ];

  environment.systemPackages = [ pkgs.nixos-nspawn ];

  networking.hosts."beef::1" = [ "containerhost" "containerhost.local" ];

  systemd.network = {
    netdevs."40-${bridgeName}".netdevConfig = {
      Name = bridgeName;
      Kind = "bridge";
    };

    networks."40-${bridgeName}" = {
      name = bridgeName;
      networkConfig = {
        Address = [ "192.168.25.1/24" "beef::1/64" ];
        LinkLocalAddressing = "ipv6";
        IPMasquerade = "both";
        LLDP = true;
        EmitLLDP = "customer-bridge";
        DHCPServer = true;
        IPv6SendRA = true;
        IPv6AcceptRA = false;
      };
      ipv6Prefixes = [{
        Prefix = "beef::/64";
      }];
    };
  };
}
