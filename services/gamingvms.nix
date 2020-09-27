{ config, pkgs, ... }:
let
  ip = "${pkgs.iproute}/bin/ip";
  ovmf = "${pkgs.OVMF.fd}/FV";
  patchedRom = pkgs.requireFile {
    name = "GM204-new-patched.rom";
    sha256 = "0kdb3wzr6441bj6j2mdlrb94bsz075lmn0l9ic0f4x87dmgibkh0";
    message = ''
      Need ROM for GTX 970
      Add it to the store with nix-store --add-fixed sha256 GM204-new-patched.rom
    '';
  };

  mkVm = {name, tap, mac, extraArgs}: let
    monitorSocket = "/run/${name}vm/qemu.sock";
  in {
    description = "VM for ${name}";
    after = [ "network.target" "zfs-import.target" ];
    # wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;

    serviceConfig = {
      Restart = "no";
      RuntimeDirectory = "${name}vm";
      WorkingDirectory = "/run/${name}vm";
    };

    script = ''${pkgs.qemu}/bin/qemu-system-x86_64 \
      -name guest=win10-${name} \
      -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
      -machine pc-q35-5.1,mem-merge=on,pflash0=pflash0-blkdev,pflash1=pflash1-blkdev \
      -accel kvm,kernel-irqchip=on \
      -cpu host,hv_passthrough,hv_vendor_id=m1cr0man,-vmx,kvm=off \
      -smp 6,sockets=1,cores=3,threads=2,maxcpus=6 \
      -m 12288 \
      -overcommit mem-lock=off \
      -rtc base=localtime,driftfix=slew \
      -global kvm-pit.lost_tick_policy=delay \
      -no-hpet \
      -monitor unix:${monitorSocket},server,nowait \
      -monitor stdio \
      -nodefaults \
      -display none \
      -vga none \
      -netdev tap,fd=7,id=hostnet0 \
      -blockdev node-name=os-storage,driver=host_device,filename=/dev/zvol/zroot/vms/windows-${name},discard=unmap,aio=native,cache.direct=on \
      -blockdev node-name=pflash0-blkdev,driver=file,filename=${ovmf}/OVMF_CODE.fd,read-only=on \
      -blockdev node-name=pflash1-blkdev,driver=file,filename=${ovmf}/OVMF_VARS.fd,read-only=on \
      -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=rp0 \
      -device pcie-root-port,bus=pcie.0,multifunction=on,port=2,chassis=2,id=rp1 \
      -device qemu-xhci,id=xhci0,multifunction=on,bus=rp0,addr=00.0 \
      -device virtio-net,netdev=hostnet0,id=net0,mac=${mac},bus=rp0,addr=00.1 \
      -device virtio-blk-pci,drive=os-storage,bootindex=1,id=virtio-disk0,bus=rp0,addr=00.2 \
      -device ich9-usb-ehci1,id=usb0,multifunction=on,bus=rp0,addr=00.3 \
      -device virtio-balloon-pci,id=balloon0,bus=rp0,addr=00.4 \
      ${builtins.concatStringsSep " " extraArgs} \
      7<>/dev/tap$(< /sys/class/net/${tap}/ifindex)
    '';

    preStart = ''
      if ! test -e /sys/class/net/${tap}; then
        ${ip} l add name ${tap} link eth0 type macvtap mode bridge
      fi
      ${ip} l set dev ${tap} addr ${mac}
      ${ip} l set ${tap} up
    '';

    preStop = "${pkgs.socat}/bin/socat - unix-connect:${monitorSocket} <(echo system_powerdown) && ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null";
  };
in {
  systemd.services.lucasvm = mkVm {
    name = "lucas";
    tap = "macvtap0";
    mac = "52:54:00:e2:d6:77";
    extraArgs = [
      "-device vfio-pci,host=0000:07:00.0,id=hostdevxfi,bus=rp0,addr=00.5"
      "-device vfio-pci,host=0000:03:00.0,id=hostdevgpu,romfile=/root/GM204-new-patched.rom,multifunction=on,x-vga=on,bus=rp1,addr=00.0"
      "-device vfio-pci,host=0000:03:00.1,id=hostdevgpuhda,bus=rp1,addr=00.1"
      "-device usb-host,bus=xhci0.0,vendorid=0x10f5,productid=0x0292"
      "-device usb-host,bus=xhci0.0,vendorid=0x12cf,productid=0x0170"
      "-device usb-host,bus=xhci0.0,vendorid=0x13ba,productid=0x0018"
      "-device usb-host,bus=usb0.0,hostbus=4,hostport=1.2"
      "-blockdev node-name=data-disk-1,driver=host_device,filename=/dev/disk/by-id/ata-WDC_WD10EZEX-22RKKA0_WD-WCC1S3302032,aio=native,cache.direct=on"
      "-blockdev node-name=data-disk-2,driver=host_device,filename=/dev/disk/by-id/ata-WDC_WD10EZEX-00RKKA0_WD-WCC1S4247936,aio=native,cache.direct=on"
      "-device virtio-blk-pci,drive=data-disk-1,bootindex=2,id=virtio-disk1,bus=rp0,addr=00.6"
      "-device virtio-blk-pci,drive=data-disk-2,bootindex=3,id=virtio-disk2,bus=rp0,addr=00.7"
    ];
  };
  systemd.services.adamvm = mkVm {
    name = "adam";
    tap = "macvtap1";
    mac = "52:54:00:e2:d6:78";
    extraArgs = [
      "-device vfio-pci,host=0000:00:1b.0,id=hostdevhda,bus=rp0,addr=00.5"
      "-device vfio-pci,host=0000:04:00.0,id=hostdevgpu,romfile=/root/GM204-new-patched.rom,multifunction=on,x-vga=on,bus=rp1,addr=00.0"
      "-device vfio-pci,host=0000:04:00.1,id=hostdevgpuhda,bus=rp1,addr=00.1"
      "-device usb-host,bus=xhci0.0,vendorid=0x1532,productid=0x0109"
      "-device usb-host,bus=xhci0.0,vendorid=0x04f3,productid=0x02f0"
      "-device usb-host,bus=xhci0.0,vendorid=0x10f5,productid=0x0292"
      "-device usb-host,bus=usb0.0,hostbus=4,hostport=1.1"
    ];
  };
}
