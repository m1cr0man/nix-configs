{ config, lib, ... }: let
  klipperUser = config.services.klipper.user;
  moonrakerUser = config.services.moonraker.user;
in  {
  preservation.enable = true;
  preservation.preserveAt."/nix/persist" = {
    commonMountOptions = [ "x-gvfs-hide" "x-gdu.hide" ];
    directories = let
      init = directory: { inherit directory; inInitrd = true; configureParent = true; };
    in [
      (init "/var/lib/nixos")
      "/home"
      "/root"
      "/var/log"
      "/var/lib/systemd/timers"
      "/var/lib/tailscale"
      { directory = "/var/lib/klipper"; user = klipperUser; group = klipperUser; }
      { directory = "/var/lib/moonraker"; user = moonrakerUser; group = moonrakerUser; }
    ];
    files = let
      init = file: { inherit file; how = "bindmount"; inInitrd = true; configureParent = true; };
    in [
      (init "/var/lib/systemd/random-seed")
      (init "/etc/machine-id")
    ];
  };

  sops.age.sshKeyPaths = lib.mkForce [
    "/nix/persist/ssh_host_ed25519_key"
  ];

  services.openssh.hostKeys = lib.mkForce [{
    path = "/nix/persist/ssh_host_ed25519_key";
    type = "ed25519";
  }];
}
