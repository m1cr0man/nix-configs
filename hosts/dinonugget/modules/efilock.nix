{ pkgs, ... }: {
  systemd.services.efilock = {
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    description = "Lock current boot entry as next boot entry";
    path = [ pkgs.efibootmgr pkgs.gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      efibootmgr -n $(efibootmgr | grep BootCurrent | grep -Eo '[0-9]+')
    '';
  };
}
