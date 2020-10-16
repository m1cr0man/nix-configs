{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = true;
    forceImportAll = false;
  };
  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 1;
  };
}
