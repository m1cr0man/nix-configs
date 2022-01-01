{
  boot.isContainer = true;

  networking.useDHCP = false;
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.httpd = {
    enable = true;
    adminAddr = "lucas@m1cr0man.com";
  };
}
