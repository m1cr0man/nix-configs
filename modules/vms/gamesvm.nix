{ config, pkgs, ... }:
let
  ovmf = "${pkgs.OVMF.fd}/FV";
  drive_c = "/var/lib/vms/gamesvm_c.qcow2";
  drive_d = "/var/lib/vms/ssd/gamesvm_d.qcow2";
  spice_secret_file = config.sops.secrets.spice_password.path;
  qemu = pkgs.qemu.override {
    hostCpuOnly = true;
    smbdSupport = true;
    alsaSupport = false;
    pulseSupport = false;
    smartcardSupport = false;
    jackSupport = false;
    sdlSupport = false;
    gtkSupport = false;
    ncursesSupport = false;
  };
in
{
  sops.secrets.spice_password = { };

  systemd.services.gamesvm = {
    description = "Games VM";
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    path = [ pkgs.qemu pkgs.samba ];

    # hostfwd=[tcp|udp]:[hostaddr]:hostport-[guestaddr]:guestport
    # -drive file=/var/lib/vms/win10_21h2_x64.iso,index=0,media=cdrom \
    # -drive file=/var/lib/vms/virtio-win.iso,index=1,media=cdrom \
    script = ''
      cp ${ovmf}/OVMF_VARS.fd OVMF_VARS_gamesvm.fd
      qemu-system-x86_64 \
        -name guest=gamesvm \
        -machine pc-q35-7.0,pflash0=pflash0-blkdev,pflash1=pflash1-blkdev \
        -accel kvm,kernel-irqchip=on \
        -cpu host,hv_passthrough,kvm=off,-vmx  \
        -smp 6,cores=3,threads=2,sockets=1,maxcpus=6 \
        -m 16G \
        -overcommit mem-lock=off \
        -rtc base=localtime,driftfix=slew \
        -global kvm-pit.lost_tick_policy=delay \
        -no-hpet \
        -nodefaults \
        -vga qxl \
        --object secret,id=spicesec0,file='${spice_secret_file}' \
        -spice ipv4=on,port=5910,addr=0.0.0.0,password-secret=spicesec0 \
        -device virtio-serial-pci \
        -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
        -chardev spicevmc,id=spicechannel0,name=vdagent \
        -monitor unix:gamesvm.sock,server,nowait \
        -monitor stdio \
        -boot menu=on,splash-time=3000 \
        -blockdev node-name=pflash0-blkdev,driver=file,filename=${ovmf}/OVMF_CODE.fd,read-only=on \
        -blockdev node-name=pflash1-blkdev,driver=file,filename=OVMF_VARS_gamesvm.fd,read-only=off \
        -drive file=${drive_c},if=none,id=os-storage \
        -drive file=${drive_d},if=none,id=ssd-storage \
        -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=rp0 \
        -device virtio-blk-pci,drive=os-storage,bootindex=1,id=virtio-disk0,bus=rp0,addr=00.0 \
        -device virtio-blk-pci,drive=ssd-storage,bootindex=2,id=virtio-disk1,bus=rp0,addr=01.0 \
        -device virtio-balloon-pci,id=balloon0,bus=rp0,addr=02.0 \
        -device ich9-intel-hda,id=hda-0,bus=rp0,multifunction=on,addr=03.0 \
        -device hda-duplex,id=hda-duplex-0,bus=hda-0.0,cad=0 \
        -nic user,model=virtio,id=vmnet0,hostname=gamesvm,hostfwd=udp::27016-:27016 \
    '';

    preStop = ''
      set -euxo pipefail
      [ -n "''${MAINPID:-}" -a -e "/proc/''${MAINPID:-}" ] || exit 0
      echo -e 'system_powerdown\nsystem_powerdown' | ${pkgs.socat}/bin/socat - unix-connect:gamesvm.sock
      ${pkgs.coreutils}/bin/tail --pid="$MAINPID" -f /dev/null &
      sleep 30 &
      wait -n
      [ -e "/proc/$MAINPID" ] || exit 0
      echo quit | ${pkgs.socat}/bin/socat - unix-connect:gamesvm.sock
      ${pkgs.coreutils}/bin/tail --pid="$MAINPID" -f /dev/null &
      sleep 10 &
      wait -n
    '';

    serviceConfig = {
      RestartSec = 60;
      Restart = "on-failure";
      RuntimeDirectory = "gamesvm";
      WorkingDirectory = "/run/gamesvm";
    };

    unitConfig = {
      RequiresMountsFor = [ "/var/lib/vms" "/var/lib/vms/ssd" ];
    };
  };
}
