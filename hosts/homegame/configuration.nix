{ config, pkgs, ... }:
let
  steamEx = with pkgs; steam.override {
    extraPkgs = pkgs: [ gcc-unwrapped glib json-glib ];
  };
in
{

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
      ../../services/ssh.nix
    ];

  system.stateVersion = "21.03";

  boot.loader.efi = {
    efiSysMountPoint = "/boot";
    canTouchEfiVariables = true;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  networking = {
    hostId = "e4a13b4c";
    hostName = "homegame";
    useDHCP = false;

    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.14.3";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.14.254";
    nameservers = [ "192.168.14.254" "1.1.1.1" ];
  };

  environment.systemPackages = with pkgs; [
    steamEx
    opera
    wine-staging
    lutris
    discord
    xorg.xf86inputjoystick
    nfs-utils
    pciutils
    vaapiIntel
    libva
    libglvnd
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

  users.users.lucas = {
    home = "/home/lucas";
    shell = pkgs.bashInteractive;
    group = "lucas";
    extraGroups = [ "wheel" ];
  };
  users.groups.lucas = { };
}
