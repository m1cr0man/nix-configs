{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    "${<nixpkgs>}/nixos/modules/installer/netboot/netboot-minimal.nix"
    ../../common/sysconfig.nix
    ../../services/ssh.nix
  ];

  services.getty.autologinUser = mkForce "root";
  # Enable sshd which gets disabled by netboot-minimal.nix
  systemd.services.sshd.wantedBy = mkOverride 0 [ "multi-user.target" ];
}
