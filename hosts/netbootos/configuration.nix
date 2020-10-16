{ config, pkgs, ... }:
let
  secrets = import ../../common/secrets.nix;
  bootServer = "192.168.14.2";
in {

  imports =
    [
      ./hardware-configuration.nix
      ../../common/sysconfig.nix
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
    useDHCP = true;
    # Keep DHCP IP during shutdown
    dhcpcd.persistent = true;
    usePredictableInterfaceNames = false;
    wireless.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xorg.xf86videoqxl
  ];

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.lxqt.enable = true;
    libinput.enable = true;
    videoDrivers = [ "nvidia" "nvidiaLegacy390" "qxl" "vesa" "modesetting" ];
  };

  users.users.lucas = {
    home = "/home/lucas";
    shell = pkgs.bashInteractive;
    group = "lucas";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$T.30dsULLs$bHXslyJmCjpnNgOvXFmhox8X7YDihXBiaK8pJOyLecpEl9eYu8MMVsFGAnNOvN4sX9HEtNOo5ti71h2lQB5EB.";
  };
  users.groups.lucas = {};
}
