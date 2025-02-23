{ pkgs, lib, modulesPath, ... }: {
  imports = with lib.m1cr0man.module;
    addModules ../../modules [
      "management/ssh"
    ]
    ++
    [
      "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ];

  system.stateVersion = "25.05";
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # So that nix copy works
  nix.settings.trusted-users = [ "root" "nixos" ];

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  users.mutableUsers = false;
  # nixosinstaller
  users.users.root.hashedPassword = "$6$H07ql2WP0TIHXUzs$mZyWTiS2oH2bNATncMEqQNy.ps200fCyOPvpneMc8IVCXNEoZtdNSBuO.2/yvdxoyilBG2QwJEOXz9c.wYR000";
  users.users.nixos.hashedPassword = "$6$H07ql2WP0TIHXUzs$mZyWTiS2oH2bNATncMEqQNy.ps200fCyOPvpneMc8IVCXNEoZtdNSBuO.2/yvdxoyilBG2QwJEOXz9c.wYR000";

  networking.wireless.enable = true;
  networking.wireless.allowAuxiliaryImperativeNetworks = true;
  networking.useDHCP = true;
  networking.useNetworkd = true;
  networking.usePredictableInterfaceNames = false;
}
