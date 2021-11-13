{ config, pkgs, ... }:
let
  name = "manjaro";
  dataDir = "/opt/vms/${name}";
  diskImage = "${dataDir}/sda.qcow2";
  sshForwardPort = 2222;
  vncPort = 5900;

  ovmf = "${pkgs.OVMF.fd}/FV";
  qemu = pkgs.qemu-host-cpu-only;
  shutdownCommand = pkgs.writeText "${name}-shutdown" "system_powerdown\n";
in {
  systemd.services."${name}" = {
    description = "${name} VM";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      mkdir -p ${dataDir}
      test -e ${diskImage} || ${qemu}/bin/qemu-img create -f qcow2 ${diskImage} 200G -o cluster_size=8192,compat=v3
      test -e ${dataDir}/OVMF_VARS.fd || cp ${ovmf}/OVMF_VARS.fd ${dataDir}/
    '';

    serviceConfig = {
      ExecStart = ''
        ${qemu}/bin/qemu-system-x86_64 -enable-kvm \
          -name guest=${name} \
          -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
          -machine pc-q35-5.1,mem-merge=on,pflash0=pflash0-blkdev,pflash1=pflash1-blkdev \
          -accel kvm,kernel-irqchip=on \
          -overcommit mem-lock=off \
          -rtc base=localtime,driftfix=slew \
          -global kvm-pit.lost_tick_policy=delay \
          -no-hpet \
          -cpu host,hv_passthrough \
          -smp 4,cores=2,threads=2,sockets=1,maxcpus=4 \
          -m 8G \
          -vga qxl \
          -boot menu=on,splash-time=5000 \
          -drive file=${diskImage},if=virtio,format=qcow2 \
          -drive file=/opt/generic/virtio-win.iso,index=1,media=cdrom \
          -netdev user,id=n1,hostfwd=tcp::${sshForwardPort}-:22 \
          -device virtio-net,netdev=n1 \
          -blockdev node-name=pflash0-blkdev,driver=file,filename=${ovmf}/OVMF_CODE.fd,read-only=on \
          -blockdev node-name=pflash1-blkdev,driver=file,filename=${dataDir}/OVMF_VARS.fd \
          -spice port=${vncPort},addr=127.0.0.1,disable-ticketing \
          -device virtio-serial-pci \
          -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
          -chardev spicevmc,id=spicechannel0,name=vdagent \
          -monitor unix:/var/run/${name}/monitor.sock,server,nowait \
          -monitor stdio
      '';
      ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.socat}/bin/socat - unix-connect:/var/run/${name}/monitor.sock < ${shutdownCommand} && ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null'";
      RestartSec = 10;
      Restart = "always";
      RuntimeDirectory = name;
      WorkingDirectory = "/opt/vms";
    };
  };
}
