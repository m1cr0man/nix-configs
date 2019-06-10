{
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqatoGLGjnuRUhMV5gXcNDhNs3pm/escyEXn8s9Nft4 lucas@sentinel-prime"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPR+OTAIYr02f/WKQSXo7zYy9tkuAHYpy0ajqY6aJ7Nk m1cr0man@redbrick.dcu.ie"
  ];
}
