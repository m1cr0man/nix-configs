{ pkgs, ... }: {
  # Display driver
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Boot screen
  boot.plymouth.enable = true;

  # Desktop Environment
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  # The correct package for KDE connect is already set in the plasma6 module
  programs.kdeconnect.enable = true;

  # Login
  services.displayManager.sddm = {
    enable = true;
    # Absolutely necessary to not black screen on login
    wayland.enable = true;
  };
  # Use wayland (x11 has the suffix x11)
  services.displayManager.defaultSession = "plasma";

  # Themeing
  programs.dconf.enable = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
    ];
  };

  # From AMD GPU on NixOS Wiki
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Sound
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
    settings."allow-preset-passphrase" = "";
  };
  security.pam.services.login.gnupg.enable = true;

  environment.defaultPackages = [
    pkgs.clinfo
    pkgs.glxinfo
    pkgs.vulkan-tools
    pkgs.vulkan-loader
    pkgs.libva-utils
    # Enables desktop sharing in Discord and the likes
    pkgs.kdePackages.xwaylandvideobridge
  ];
}
