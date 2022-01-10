# This entire file is a hack. Don't try this at home :D
{ pkgs, self }:
pkgs.symlinkJoin {
  name = "netboot";
  paths = with self.nixosConfigurations.netboot.config.system.build; [
    netbootRamdisk
    kernel
    netbootIpxeScript
  ];
  preferLocalBuild = true;
}
