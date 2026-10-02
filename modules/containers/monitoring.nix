{
  imports = [
    ../monitoring/client
  ];

  # Always enable systemd metrics
  m1cr0man.monitoring.systemdMetrics = true;

  # Allow vector and sded to be scraped
  networking.firewall.allowedTCPPorts = [ 9136 9137 ];
}
