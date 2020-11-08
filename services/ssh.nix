{
  services.openssh.enable = true;
  services.openssh.gatewayPorts = "yes";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqatoGLGjnuRUhMV5gXcNDhNs3pm/escyEXn8s9Nft4 lucas@sentinel-prime"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPR+OTAIYr02f/WKQSXo7zYy9tkuAHYpy0ajqY6aJ7Nk m1cr0man@redbrick.dcu.ie"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYKnYP4Mmyk4wQE7J6Tyr27XToKtxAhXBZr5HkEXiFq root@gelandewagen"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnVLSh0OStxZTkXE6oGgwfFvsbvN6bFPlVfDYOwtnzn lucas@oatfield"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZRqQtVCoRxkYXZS9kr3AVuxi6Zz87j/xeHWsJFDadd lucas@OnePlusOne"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFvcG7o/SHHzXALASd6GN5DCPR1tpZz6st5X29iGoT9 lucas@ascension"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBk0nZhDDU5ih0F5HqZ581ZXL7cbsdCEEJ2WFEiq6jJb lucas@netbootos"
  ];
}
