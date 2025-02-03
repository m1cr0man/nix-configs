{ pkgs, lib, ... }: {
  system.stateVersion = "24.11";

  m1cr0man.zfs.enable = false;

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.hostPlatform.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.

  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi3;
}
