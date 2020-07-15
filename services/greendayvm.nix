{ config, pkgs, ... }:
let
  tap = "macvtap0";
  mac = "00:50:56:00:AD:D9";
  ip = "${pkgs.iproute}/bin/ip";
in {
  systemd.services.greendayvm = {
    description = "Greenday's VM";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];
        script = ''
		${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm \
		  -machine q35 \
		  -cpu host -smp 2,cores=1,threads=2,sockets=1,maxcpus=2 -m 4G \
		  -drive file=/opt/generic/vms/greenday.img,if=virtio,format=raw \
                  -cdrom /opt/generic/ubuntu-18.04.3-live-server-amd64.iso \
		  -vga qxl \
		  -spice port=5905,addr=127.0.0.1,disable-ticketing \
		  -device virtio-serial-pci \
		  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
		  -chardev spicevmc,id=spicechannel0,name=vdagent \
		  -monitor unix:/var/run/greendayvm.sock,server,nowait \
                  -monitor stdio \
                  -boot menu=on,splash-time=5000 \
                  -nic tap,fd=5,model=virtio,mac=${mac} \
		  5<>/dev/tap$(< /sys/class/net/${tap}/ifindex)
	'';

    preStart = ''
      if ! test -e /sys/class/net/${tap}; then
        ${ip} l add name ${tap} link eth0 type macvtap mode bridge
      fi
      ${ip} l set dev ${tap} addr ${mac}
      ${ip} l set ${tap} up
    '';
    preStop = "${pkgs.socat}/bin/socat - unix-connect:/var/run/greendayvm.sock <(echo system_powerdown) && ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null";
    restartIfChanged = false;

    serviceConfig = {
      RestartSec = 10;
      Restart = "always";
      WorkingDirectory = "/opt/generic/vms";
    };
  };
}
