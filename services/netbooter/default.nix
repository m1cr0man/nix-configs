{ pkgs, config, ... }:
let
  menuFileName = "menu.ipxe";
  externalRoot = "/var/lib/netboot-root";

  dhcpProxyAddress = config.m1cr0man.netbooter.dhcpProxyAddress;
  dhcpRange = config.m1cr0man.netbooter.dhcpRange;
  hostIp = config.m1cr0man.netbooter.hostIp;
  httpPort = 8069;

  nixOS = import ../../hosts/netboot/build-image.nix { inherit pkgs; };

  ipxeScript = pkgs.writeTextFile {
    name = menuFileName;
    text = ''
      #!ipxe

      :mainmenu
      menu Select an option

      item nixos NixOS
      item external External

      choose os

      goto ''${os}

      :nixos
      chain --replace http://${hostIp}:${toString httpPort}/netboot.ipxe

      :external
      chain --replace http://${hostIp}:${toString httpPort}/external/menu.ipxe
    '';
  };

  dhcpListenConfig = if dhcpRange != null then ''
    dhcp-range=${dhcpRange},12h
    dhcp-authoritative
  '' else ''
    dhcp-range=${dhcpProxyAddress},proxy
  '';

  # Embed ipxe script into the image for faster booting
  # ipxeEmbedded = pkgs.ipxe.override { embedScript = ipxeScript; };

  # Root for TFTP + HTTP
  netbootRoot = with pkgs; symlinkJoin {
    name = "netboot-tftp-root";
    paths = [
      ipxe
      nixOS
      (runCommand "netboot-symlinks" {} ''
        mkdir -p $out
        ln -s /var/lib/netboot $out/external
        ln -s ${ipxeScript} $out/${menuFileName}
      '')
    ];
    preferLocalBuild = true;
  };
in {
  assertions = [{
    assertion = dhcpRange == null || dhcpProxyAddress == null;
    message = ''
      Options `m1cr0man.netbooter.dhcpRange` and
      `m1cr0man.netbooter.dhcpProxyAddress` are mutually exclusive.
    '';
  }];

  services.lighttpd = {
    enable = true;
    port = httpPort;
    document-root = netbootRoot;
    extraConfig = ''
      dir-listing.activate = "enable"
    '';
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      port=0
      listen-address=${hostIp}
      log-dhcp
      enable-tftp
      tftp-root=${netbootRoot}

      ${dhcpListenConfig}

      # Speed up DHCP when no proxy is in use (set no-proxydhcp)
      dhcp-option=encap:175,176,1
      dhcp-option=176,1

      # Disable re-use of the DHCP servername and filename fields as extra
      # option space. That's to avoid confusing some old or broken DHCP clients.
      dhcp-no-override

      # Match syntax here is set:$VARNAME,$TAG[,$VALUE]
      dhcp-match=set:iPXE,175
      dhcp-match=set:uefi, option:client-arch, 6
      dhcp-match=set:uefi, option:client-arch, 7
      dhcp-match=set:uefi, option:client-arch, 9
      dhcp-boot=tag:iPXE,${menuFileName},,${hostIp}
      dhcp-boot=tag:!iPXE,tag:uefi,ipxe.efi,,${hostIp}
      dhcp-boot=tag:!iPXE,tag:!uefi,undionly.kpxe,,${hostIp}
    '';
  };

  # Used for leasefile
  systemd.services.dnsmasq.serviceConfig.StateDirectory = "dnsmasq";

  networking.firewall.allowedTCPPorts = [ 67 httpPort ];
  networking.firewall.allowedUDPPorts = [ 67 69 ];
}
