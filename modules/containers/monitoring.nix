{
  imports = [
    ../monitoring/client
  ];

  # Always enable systemd metrics
  m1cr0man.monitoring.systemdMetrics = true;
}
