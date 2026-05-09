{ pkgs, ... }: {
  # Boot screen
  boot.plymouth.enable = true;

  # Desktop Environment
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  # The correct package for KDE connect is already set in the plasma6 module
  programs.kdeconnect.enable = true;

  # Login
  services.displayManager.plasma-login-manager.enable = true;

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

  # Unused programs
  programs.kde-pim.enable = false;

  environment.defaultPackages = [
    pkgs.clinfo
    pkgs.vulkan-tools
    pkgs.vulkan-loader
    pkgs.libva-utils
  ];
}
