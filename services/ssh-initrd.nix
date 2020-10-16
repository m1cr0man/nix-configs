{ config, lib, ... }:
{
  options.m1cr0man.resetNetworkAfterInitrd = lib.mkOption {
    description = "Whether to drop any DHCP leases received during initrd network setup";
    default = false;
    defaultText = "False";
    type = lib.types.bool;
  };

  # Enable shell during boot
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 6416;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      hostKeys = [
        /var/secrets/ssh_initrd_host_ed25519_key
      ];
    };
  };

  # Use DHCP during the initrd, then undo the config before stage 2 boot
  boot.initrd.postMountCommands = lib.mkIf config.m1cr0man.resetNetworkAfterInitrd ''
    ip a flush eth0
    ip l set eth0 down
  '';
}
