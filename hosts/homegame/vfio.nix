{
  boot.kernelModules = [ "vfio" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" "snd_ctxfi" "snd_hda_intel" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:13c2,10de:0fbb,1102:000b
    options vfio_iommu_type1 allow_unsafe_interrupts=1
  '';
  # options kvm ignore_msrs=1

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
  };
}
