{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.boot.loader.rpi;
  rpi-boot-builder = pkgs.writeShellApplication {
    name = "rpi-boot-builder.sh";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
    ];
    text = ''
      shopt -s nullglob
      DEST_DIR='${cfg.mountpoint}'

      cd '${pkgs.raspberrypifw}/share/raspberrypi/boot'
      FW_FILES=(
        overlays
        *.dtb
        bootcode.bin
        fixup*.dat
        start.elf
        start${lib.optionalString (cfg.stripRpi4) "[!4]"}*.elf
      )

      find "$DEST_DIR" -mindepth 1 -delete
      cp -r -t "$DEST_DIR" "''${FW_FILES[@]}"

      cp -t "$DEST_DIR" "$1"/{kernel,initrd}
      echo "$(cat "$1/kernel-params") init=$1/init" > "$DEST_DIR/cmdline.txt"
      cp '${cfg.configFile}' "$DEST_DIR/config.txt"

      echo "RPi bootloader configured"
    '';
  };
in
{
  options.boot.loader.rpi = {
    enable = lib.mkEnableOption "native Raspberry Pi bootloader";
    configFile = lib.mkOption {
      default = ./config.txt;
      type = lib.types.pathInStore;
      description = "The RPi boot config to install";
    };
    mountpoint = lib.mkOption {
      default = "/boot/firmware";
      type = lib.types.path;
      description = "Mount point of the boot/firmware directory";
    };
    stripRpi4 = lib.mkEnableOption "removal of RPi 4 boot files to save a few mb";
  };

  config = lib.mkIf cfg.enable {
    system.boot.loader.id = "rpi";
    system.build.installBootLoader = "${rpi-boot-builder}/bin/rpi-boot-builder.sh";
    boot = {
      kernelParams = [
        "console=tty1"
        # Enables UART0
        "8250.nr_uarts=1"
      ];
      loader.grub.enable = false;
      initrd.availableKernelModules = [
        "pcie_brcmstb" # required for the pcie bus to work
        "reset-raspberrypi" # required for vl805 firmware to load
        "usb_storage"
        "usbhid"
        "vc4"
      ];
    };
  };
}
