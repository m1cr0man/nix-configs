{ config, pkgs, ... }:
let
  shutdownCommand = pkgs.writeText "desktopvm-shutdown" "system_powerdown\n";
  oldQemu = pkgs.qemu_kvm.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://wiki.qemu.org/download/qemu-3.1.0.tar.bz2";
      sha256 = "08frr1fdjx8qcfh3fafn10kibdwbvkqqvfl7hpqbm7i9dg4f1zlq";
    };
    version = "3.1.0";
    name = "qemu-host-cpu-only-3.1.0";
  });
in {
  systemd.services.desktopvm = {
    description = "Solus VM";
    after = [ "network.target" "zfs-import.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
        ExecStart = ''
		${oldQemu}/bin/qemu-system-x86_64 -enable-kvm \
		  -machine q35 \
		  -cpu host -smp 4,cores=2,threads=2,sockets=1,maxcpus=4 -m 8G \
		  -drive file=/opt/vms/endgame.img,if=virtio,format=raw \
		  -vga qxl \
		  -spice port=5900,addr=127.0.0.1,disable-ticketing \
		  -device virtio-serial-pci \
		  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
		  -chardev spicevmc,id=spicechannel0,name=vdagent \
		  -netdev user,id=n1,hostfwd=tcp::2222-:22 \
		  -device virtio-net,netdev=n1 \
		  -monitor unix:/var/run/desktopvm.sock,server,nowait \
                  -monitor stdio
	'';
	ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.socat}/bin/socat - unix-connect:/var/run/desktopvm.sock < ${shutdownCommand} && ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null'";
	RestartSec = 10;
        Restart = "always";
        WorkingDirectory = "/opt/vms";
    };
  };
}
