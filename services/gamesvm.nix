{ config, pkgs, ... }:
let
  secrets = import ../common/secrets.nix;
  ovmf = "${pkgs.OVMF.fd}/FV";
  cert = config.security.acme.certs."m1cr0man.com".directory;
in {
  networking.firewall.allowedTCPPorts = [ 5910 ];
  systemd.services.gamesvm = {
    description = "Games VM";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;

                  #-drive file=/opt/generic/Win10_20H2_English_x64.iso,index=0,media=cdrom \
                  #-drive file=/opt/generic/virtio-win.iso,index=1,media=cdrom \
    script = ''
                cp ${ovmf}/OVMF_VARS.fd /var/run/OVMF_VARS_gamesvm.fd
		${pkgs.qemu}/bin/qemu-system-x86_64 \
                  -name guest=gamesvm \
                  -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
		  -machine pc-q35-5.1,pflash0=pflash0-blkdev,pflash1=pflash1-blkdev \
                  -accel kvm \
		  -cpu host,hv_passthrough,kvm=off,-vmx  \
                  -smp 2,cores=1,threads=2,sockets=1,maxcpus=2 \
                  -m 2G \
                  -no-hpet \
                  -nodefaults \
		  -vga qxl \
		  -spice ipv4,tls-port=5910,addr=0.0.0.0,password=${secrets.gamesvm_spice_password},tls-ciphers=HIGH,x509-key-file=${cert}/key.pem,x509-cert-file=${cert}/cert.pem,x509-cacert-file=${cert}/chain.pem \
		  -device virtio-serial-pci \
		  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
		  -chardev spicevmc,id=spicechannel0,name=vdagent \
		  -monitor unix:/var/run/gamesvm.sock,server,nowait \
                  -monitor stdio \
                  -boot menu=on,splash-time=5000 \
                  -blockdev node-name=pflash0-blkdev,driver=file,filename=${ovmf}/OVMF_CODE.fd,read-only=on \
                  -blockdev node-name=pflash1-blkdev,driver=file,filename=/var/run/OVMF_VARS_gamesvm.fd,read-only=off \
                  -blockdev node-name=os-storage,driver=host_device,filename=/dev/zvol/zstorage/vms/games_c,aio=native,cache.direct=on \
                  -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=rp0 \
                  -device virtio-blk-pci,drive=os-storage,bootindex=1,id=virtio-disk0,bus=rp0,addr=00.0 \
                  -nic user,model=virtio,id=vmnet0,net=192.168.0.0/24,dhcpstart=192.168.0.9,dns=192.168.0.3,hostname=gamesvm
	'';

    preStop = ''
      echo -e 'system_powerdown\nsystem_powerdown' | ${pkgs.socat}/bin/socat - unix-connect:/var/run/gamesvm.sock
      ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null &
      sleep 30 &
      wait -n
      [ -e /proc/$MAINPID ] || exit 0
      echo quit | ${pkgs.socat}/bin/socat - unix-connect:/var/run/gamesvm.sock
      ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null &
      sleep 10 &
      wait -n
    '';

    serviceConfig = {
      RestartSec = 60;
      Restart = "always";
      WorkingDirectory = "/opt/generic/vms";
    };
  };
}
