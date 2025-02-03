{ lib, ... }: {
  preservation.enable = true;
  preservation.preserveAt."/nix/persist" = {
    commonMountOptions = [ "x-gvfs-hide" "x-gdu.hide" ];
    directories = let
      init = directory: { inherit directory; inInitrd = true; configureParent = true; };
    in [
      (init "/var/lib/nixos")
      "/root"
      "/var/log"
      "/var/lib/systemd/timers"
      "/var/lib/tailscale"
      { directory = "/var/lib/octoprint"; user = "octoprint"; group = "octoprint"; }
    ];
    files = let
      init = file: { inherit file; how = "symlink"; inInitrd = true; configureParent = true; };
    in [
      (init "/var/lib/systemd/random-seed")
      (init "/etc/machine-id")
      { file = "/etc/wpa_supplicant.conf"; mode = "0640"; }
    ];
  };

  services.openssh.hostKeys = lib.mkForce [{
    path = "/nix/persist/ssh_host_ed25519_key";
    type = "ed25519";
  }];
}
