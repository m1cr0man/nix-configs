{ config, pkgs, lib, ... }:
{
  jovian = {
    devices.steamdeck.enable = true;
    devices.steamdeck.enableSoundSupport = true;
    devices.steamdeck.enableMesaPatches = false;
    steam.enable = true;
  };

  services.gnome.gnome-remote-desktop.enable = false;

  # Audio stuff
  hardware.pulseaudio.enable = false;
  services.pipewire.enable = true;
  services.pipewire.wireplumber.enable = true;
  environment.systemPackages = [
    (pkgs.alsa-ucm-conf.overrideAttrs (prev: {
      # This dumb import breaks all the audio on the Deck itself.
      # Best sources as to why I could find:
      # https://github.com/alsa-project/alsa-ucm-conf/issues/104
      # see comments: https://github.com/alsa-project/alsa-ucm-conf/commit/1e6297b650114cb2e043be4c677118f971e31eb7
      postInstall = ''
        ${pkgs.gnused}/bin/sed -i /Include.libgen.File/d $out/share/alsa/ucm2/ucm.conf
      '';
      meta.priority = -10;
    }))

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
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  environment.defaultPackages = with pkgs; [
    glxinfo (steam.override { extraArgs = "-steamdeck"; })
    steamdeck-firmware
  ];

  # Updated mesa
  hardware.opengl = {
    package = pkgs.mesa_23.drivers;
    package32 = pkgs.pkgsi686Linux.mesa_23.drivers;
  };
}
