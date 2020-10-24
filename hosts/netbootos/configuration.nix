{ config, pkgs, lib, ... }:
let
  secrets = import ../../common/secrets.nix;
  bootServer = "192.168.14.2";

  steamEx = with pkgs; steam.override {
    extraPkgs = pkgs: [ gcc-unwrapped glib json-glib ];
  };
in {

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../common/users.nix
      ../../services/ssh.nix
    ];

  system.stateVersion = "21.03";

  boot.loader.grub.enable = false;
  boot.initrd.network.enable = true;
  boot.initrd.network.flushBeforeStage2 = false;

  boot.postBootCommands =
    ''
      echo Setting up
      # After booting, register the contents of the Nix store
      # in the Nix database in the tmpfs.
      ${pkgs.curl}/bin/curl -v -o- http://192.168.14.2/registration | \
        ${config.nix.package}/bin/nix-store --load-db
      # nixos-rebuild also requires a "system" profile and an
      # /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';

  networking = {
    # Blank to retrieve from DHCP
    hostName = "";
    useDHCP = lib.mkForce true;
    # Keep DHCP IP during shutdown
    dhcpcd.persistent = true;
    usePredictableInterfaceNames = false;
  };

  environment.systemPackages = with pkgs; [
    steamEx opera wine-staging lutris discord
    xorg.xf86inputjoystick nfs-utils pciutils
    vaapiIntel libva libglvnd
  ];

  # Steam support
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel libva libglvnd intel-media-driver mesa.drivers ];
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel libva libglvnd mesa.drivers ];
  hardware.pulseaudio.support32Bit = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome3.enable = true;
    libinput.enable = true;
    modules = [ pkgs.xlibs.xf86inputjoystick ];
    videoDrivers = [ "intel" "nvidia" "nvidiaLegacy390" "vesa" "modesetting" ];
  };
}
