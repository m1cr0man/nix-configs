{
  boot.kernelModules = [ "vfio" "vfio-pci" "vfio_virqfd" "vfio_iommu_type1" "xhci_pci" ];
  boot.initrd.kernelModules = [ "xhci_pci" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" "snd_ctxfi" "snd_hda_intel" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=1102:000b,8086:1d20,10de:13c2,10de:0fbb
    options vfio_iommu_type1 allow_unsafe_interrupts=1
  '';
  # options kvm ignore_msrs=1

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
  };
}
