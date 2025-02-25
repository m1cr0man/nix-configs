{ pkgs, ... }: {
  # Display driver
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Boot screen
  boot.plymouth.enable = true;

  # Desktop Environment
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Login
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  # Use wayland (x11 has the suffix x11)
  services.displayManager.defaultSession = "plasma";

  # Themeing
  programs.dconf.enable = true;
  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };

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
  ];
}
