{
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqatoGLGjnuRUhMV5gXcNDhNs3pm/escyEXn8s9Nft4 lucas@sentinel-prime"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPR+OTAIYr02f/WKQSXo7zYy9tkuAHYpy0ajqY6aJ7Nk m1cr0man@redbrick.dcu.ie"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYKnYP4Mmyk4wQE7J6Tyr27XToKtxAhXBZr5HkEXiFq root@gelandewagen"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5t+UQfxl+SK1BwTuKH2A/RQVDEJoaazmQYcRSTI/Mt root@chuck"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnVLSh0OStxZTkXE6oGgwfFvsbvN6bFPlVfDYOwtnzn lucas@oatfield"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZRqQtVCoRxkYXZS9kr3AVuxi6Zz87j/xeHWsJFDadd lucas@OnePlusOne"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFvcG7o/SHHzXALASd6GN5DCPR1tpZz6st5X29iGoT9 lucas@ascension"
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
