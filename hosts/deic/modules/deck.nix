{ config, pkgs, lib, ... }:
{
  jovian = {
    devices.steamdeck.enable = true;
    steam.enable = true;
  };

  # Use pipewire + wireplumber for all audio
  hardware.pulseaudio.enable = false;
  services.pipewire.wireplumber.enable = true;

  services.gnome.gnome-remote-desktop.enable = false;

  environment.systemPackages = [
    pkgs.gnome.gnome-tweaks
    # Tray icons
    pkgs.gnomeExtensions.appindicator
  ];

  # Required for tray icons
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

  # xserver is hangover, it will actually be wayland
  services.xserver = {
    enable = true;
    # Remap caps on the model M to super
    xkbOptions = "caps:super";
    layout = "ie";
  };

  services.xserver.desktopManager.gnome = {
    enable = true;
  };


  # Disable unwanted stuff
  programs.geary.enable = false;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-software
    gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  environment.defaultPackages = with pkgs; [
    glxinfo
    (steam.override { extraArgs = "-steamdeck"; })
    steamdeck-firmware
  ];
}
