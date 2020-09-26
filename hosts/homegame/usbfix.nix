# This script patches the Renesas firmwrae so it can
# be used in Linux. Since root is on the USB3 key it
# is needed in initrd/stage 1
{ config, pkgs, ... }:
let
  fixInitrd = pkgs.makeInitrd;
  updater = import ../../packages/upd72020x { inherit pkgs; };
in {
  config.boot.initrd = {
    extraUtilsCommands = ''
      copy_bin_and_libs ${updater}/bin/upd72020x-load
      cp -r ${updater}/firmware $out/
    '';
    extraUtilsCommandsTest = ''
      test -e $out/firmware/K2026.mem
    '';
    preDeviceCommands = ''
      upd72020x-load -u -b 0x02 -d 0x00 -f 0x0 -i "$extraUtils/firmware/K2026.mem"
      echo 1 > '/sys/bus/pci/devices/0000:00:02.0/remove'
      sleep 2
      echo 1 > /sys/bus/pci/rescan
    '';
  };
}
