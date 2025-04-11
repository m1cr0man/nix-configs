{
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5t+UQfxl+SK1BwTuKH2A/RQVDEJoaazmQYcRSTI/Mt root@chuck"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnVLSh0OStxZTkXE6oGgwfFvsbvN6bFPlVfDYOwtnzn lucas@oatfield"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINV2JF6dDjXlmUgVlzk7y5VwXx4r5+1rd95e+lU4VayA lucas@blueboi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcZTGjFqksYJQ45GJhMHlDH6VJX2zof4wUh+K/VMbfN lucas@nord2"
  ];

  services.openssh = {
    enable = true;

    # Support all types of port forwarding, including unix socket binds
    settings.GatewayPorts = "yes";
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';

    # Only enable the ed25519 host key
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Not taking any chances ;-)
  networking.firewall.allowedTCPPorts = [ 22 ];
}
