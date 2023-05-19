{ config, pkgs, lib, ... }:
let
  desktopSession = "gnome-wayland-dbus";
in
{
  jovian = {
    devices.steamdeck = {
      enable = true;
    };
    steam = {
      enable = true;
      autoStart = true;
      user = "deck";
      inherit desktopSession;
    };
  };

  # Launch wayland gnome through dbus-run-session
  services.xserver.displayManager.sessionPackages = [
    ((pkgs.runCommand "gnome-wayland-dbus-sessions" {} ''
      mkdir -p "$out/share/wayland-sessions"
      sed \
        's!Exec=!Exec=${pkgs.dbus}/bin/dbus-run-session !g' \
        '${pkgs.gnome.gnome-session.sessions}/share/wayland-sessions/gnome-wayland.desktop' \
      > "$out/share/wayland-sessions/${desktopSession}.desktop"

    '').overrideAttrs (old: {
      passthru.providedSessions = [ desktopSession ];
    }))
  ];

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
