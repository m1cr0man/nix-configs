{ pkgs, ... }:

{
  services.bind = {
    enable = true;

    # Allow underscores in domain names. Needed for DKIM key
    extraOptions = ''
      check-names master ignore;
    '';

    zones = [
      {
        name = "44.76.144.in-addr.arpa";
        file = ./in-addr.arpa.db;
        master = true;
      }
      {
        name = "m1cr0man.com";
        file = ./m1cr0man.com.db;
        master = true;
      }
      {
        name = "cragglerock.cf";
        file = ./cragglerock.cf.db;
        master = true;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
