{ config, ... }:
let
  nfsPorts = with config.services.nfs.server; [ 2049 111 lockdPort statdPort mountdPort ];
  tcpPorts = nfsPorts ++ [ 67 80 ];
  udpPorts = nfsPorts ++ [ 67 69 4011 ];

  anonuid = config.users.users.games.uid;
  anongid = config.users.groups.users.gid;
in {
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = ''
      /exports/netboot/nix_store *(ro,insecure,mountpoint,async,no_root_squash,no_subtree_check)
      /exports/games *(rw,insecure,mountpoint,async,all_squash,anonuid=${toString anonuid},anongid=${toString anongid},no_subtree_check)
      /home *(rw,insecure,mountpoint,async,no_root_squash,no_subtree_check)
    '';
  };
  services.rpcbind.enable = true;

  # NFS v4 delegation reaks havoc with the shared nix_store export
  # Disable that shit
  boot.kernel.sysctl."fs.leases-enable" = 0;

  networking.firewall.allowedTCPPorts = tcpPorts;
  networking.firewall.allowedUDPPorts = udpPorts;

  # services.dhcpd4 = {
  #   enable = true;
  #   configFile = pkgs.writeText "dhcpd4-config" ''
  #     allow booting;
  #     allow bootp;
  #     option domain-name "m1cr0man.com";

  #     subnet 192.168.14.0 netmask 255.255.255.0 {
  #       option routers 192.168.14.254;
  #     }

  #     host netboot1 {
  #       option host-name "netboot1";
  #       hardware ethernet 52:54:00:4C:FB:5E;
  #       fixed-address 192.168.14.123;
  #       next-server 192.168.14.2;
  #       if exists user-class and option user-class = "iPXE" {
  #           filename "http://192.168.14.2/netboot.ipxe";
  #       } else {
  #           filename "ipxe.efi";
  #       }
  #     }
  #   '';
  # };

  services.atftpd = {
    enable = true;
    root = "/var/lib/tftproot";
    extraOptions = [ "--verbose=7" ];
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      port=0
      log-dhcp
      dhcp-range=192.168.14.0,proxy

      # Disable re-use of the DHCP servername and filename fields as extra
      # option space. That's to avoid confusing some old or broken DHCP clients.
      dhcp-no-override

      dhcp-userclass=set:IPXE,iPXE

      # # inspect the vendor class string and match the text to set the tag
      dhcp-vendorclass=set:BIOS,PXEClient:Arch:00000
      dhcp-vendorclass=set:UEFI,PXEClient:Arch:00006
      dhcp-vendorclass=set:UEFI,PXEClient:Arch:00007
      dhcp-vendorclass=set:UEFI,PXEClient:Arch:00009

      # These don't seem to do anything...
      dhcp-boot=tag:IPXE,netboot.ipxe,,192.168.14.2
      dhcp-boot=tag:!IPXE,tag:UEFI,ipxe.efi,,192.168.14.2
      dhcp-boot=tag:!IPXE,tag:BIOS,ipxe.pxe,,192.168.14.2

      pxe-prompt="Booting iPXE", 1
      pxe-service=tag:IPXE,X86-64_EFI,"Boot file",netboot.ipxe
      pxe-service=tag:IPXE,x86PC,"Boot file",netboot.ipxe
      pxe-service=tag:!IPXE,tag:UEFI,X86-64_EFI,"Booting iPXE",ipxe.efi
      pxe-service=tag:!IPXE,tag:UEFI,x86PC,"Booting iPXE",ipxe.efi
      pxe-service=tag:!IPXE,tag:BIOS,x86PC,"Booting iPXE",ipxe.pxe
    '';
  };

  services.lighttpd = {
    enable = true;
    document-root = "/var/lib/wwwroot";
  };

}
