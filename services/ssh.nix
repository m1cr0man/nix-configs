{
  services.openssh.enable = true;
  services.openssh.gatewayPorts = "yes";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqatoGLGjnuRUhMV5gXcNDhNs3pm/escyEXn8s9Nft4 lucas@sentinel-prime"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPR+OTAIYr02f/WKQSXo7zYy9tkuAHYpy0ajqY6aJ7Nk m1cr0man@redbrick.dcu.ie"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYKnYP4Mmyk4wQE7J6Tyr27XToKtxAhXBZr5HkEXiFq root@gelandewagen"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnVLSh0OStxZTkXE6oGgwfFvsbvN6bFPlVfDYOwtnzn lucas@oatfield"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZRqQtVCoRxkYXZS9kr3AVuxi6Zz87j/xeHWsJFDadd lucas@OnePlusOne"
  ];
  users.users.portfwd-guest.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtXDL7LWBiySe4YZmosFxqzjxjcROtmse22+HFShD4L7bjpqWDkIy7ynTAn/EzizVAT2UFs2z2QObJBsaxObPMdYLpAnVW2sLKh40AhsveYlxiXhVbpfMqIZ6lqtUOMqSN3ql7eUwqWMnWtBz4yl5XwLIoNmnT20XDjNJzoGk+VOTNedldDZEM1oHOw+owtAr1k2sBu2dStXbiUgIjAyDOszNp5z1dyV8Zu/bEmFj3+Uw/JID+IneZCtk/HKrPldwv+tAbSnL2+LTmQhcdfk3GZGRh/EcAyHB+PkswIoxP7p7XoQLt10fdYYpzPur4Mo45gH/RE9ybhpxfasAj7411w== git@ip"
  ];
}
