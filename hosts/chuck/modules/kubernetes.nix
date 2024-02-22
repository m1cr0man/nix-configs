{ pkgs, lib, config, ... }:
let
  # When using easyCerts=true the IP Address must resolve to the master on creation.
  # So use simply 127.0.0.1 in that case. Otherwise you will have errors like this https://github.com/NixOS/nixpkgs/issues/59364
  kubeMasterIP = "192.168.14.1";
  kubeMasterHostname = "chuck.m1cr0man.com";
  kubeMasterAPIServerPort = 6443;
in
{
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";
  networking.firewall.trustedInterfaces = [ "flannel+" "veth+" "docker+" "cni-podman+" "lo" ];

  fileSystems."/var/lib/containerd/io.containerd.snapshotter.v1.zfs" =
    { device = "zchuck/containerd";
      fsType = "zfs";
      options = [ "nofail" ];
    };

  services.kubernetes = {
   roles = [ "master" "node" ];
   masterAddress = kubeMasterHostname;
   apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
   easyCerts = true;
   apiserver = {
     securePort = kubeMasterAPIServerPort;
     advertiseAddress = kubeMasterIP;
   };
   addons.dns.enable = true;
   kubelet.extraOpts = "--fail-swap-on=false";
  };
}
