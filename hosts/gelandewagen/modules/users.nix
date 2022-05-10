{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;
in
{
  users.groups = {
    breogan = { };
    anders = { };
    mcadmins = { };
    lucas = { };
    conor = { };
    zeus = { };
  };

  sops.secrets.portfwd_guest_password.neededForUsers = true;
  sops.secrets.zeus_password.neededForUsers = true;

  users.users = with lib.m1cr0man; lib.mkMerge [
    (makeNormalUser "anders" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuW9Vc1zz3qA++TpqLb6jTBx2ZfejO0uqrYt/tmGaEM ed25519-key-20210126"
      ];
    })

    (makeNormalUser "breogan" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIeiNkZ53utCm/d9a/m46xe00OTlRnRlrgEoiRmpW1j ed25519-key-20200418"
      ];
    })

    (makeNormalUser "conor" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUlcCjTDPA9E4Bj04kdojvsjNnXXWKhJdmrum94zUdm Conor@LAPTOP-VA4JS3RE"
      ];
      extraArgs.packages = with pkgs; [
        nodejs-14_x
      ];
    })

    (makeNormalUser "gmod" {
      description = "Garrys mod";
      group = "users";
      extraArgs = {
        extraGroups = [ "wheel" ];
        uid = 1000;
      };
    })

    (makeNormalUser "lucas" {
      extraArgs.extraGroups = [ "wheel" ];
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq17Vz/gxVGDifkRFO6W5DJvJ5JnZ+DBq85W3UtRv82 lucas@ip-svr"
      ];
    })

    (makeNormalUser "zeus" {
      keys = rootKeys ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLjzYGz5SbhwxoaVuNQr1HWJuzqshVRB3QgV3qHdFvR id_ed25519_zeuspc.pem"
      ];
      extraArgs = {
        extraGroups = [ "wheel" ];
        passwordFile = config.sops.secrets.zeus_password.path;
      };
    })

    (makeNormalUser "mcadmins" {
      keys = rootKeys ++ [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMTwoP357Z13kPk3jRc8fzSCQCIYrIe/X/a4rtKq/sPE+6ydUsXXZdcB9PvFNElDmTJGk0IoaJ6gjfjJFhzRMJvg4IKJ3mFWnkJ2FBdn+rB9CWxzx8VRZfN5Tj3BmQ/olgvxHlyI+Qh1+ceBCUH1PzNhAXTJ8uSc1rIWspunbbOU3kjW7nkf3SYCRIdHkFZXr3sf7jhw0EVvFUqfWMEl3uiEbFXzd3Hq1rFxAhvf0145ydnH/gBUyxuTP4tQDSbB3yfs8wSTRhXVDqYVz6+BKdRk67SsdY50+GR1Vp2Pd/tdmJlhu7yYyn6IPY8LIx3SGWPlk5prckDvA3I4ppdIz0ZcSgqgi9fYDmDWisaWwjPJzGlTUHLnzgxehCqrwj0qQC+k5PS6Epxq1OCyBlJcSUGgCQypLZMEOuqqf5G6ouhpvzBoDOc131Ih5Rj0zH/5r+ke+GGifoLRtbHBf2TdFjnNGjlf2XANLwHhICs3r7CPr6Kd+uQZzzApCB+wx1m8hBtax86/XqZUOr70tbbUiZvZpWzJMo7jsozsUnWfN4NBqzsyZ6/nWzpCYSXxiG8xGIptFBHr/2EsY3QaoJ8ncXdEt5d1WgqxQ3cepW+n+KYcavymy2ywO1Mij2Dwt7SobUMhkcrfVcxyFehozQAOZkZqL3ByGAaqdghpkIwn0MCQ== sailslickcode"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9ajmos3wSH3igGDzNXTC8Gpew2XfFWE17czqXXJMBs dvxl@synckey-apd"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL8j3uGq7UuFBvFrJPAzgkiaushzYnjyHYQKeQ48fgd Drumsy"
      ];
    })

    (makeNormalUser "portfwd-guest" {
      home = "/var/empty";
      group = "nogroup";
      keys = rootKeys ++ [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtXDL7LWBiySe4YZmosFxqzjxjcROtmse22+HFShD4L7bjpqWDkIy7ynTAn/EzizVAT2UFs2z2QObJBsaxObPMdYLpAnVW2sLKh40AhsveYlxiXhVbpfMqIZ6lqtUOMqSN3ql7eUwqWMnWtBz4yl5XwLIoNmnT20XDjNJzoGk+VOTNedldDZEM1oHOw+owtAr1k2sBu2dStXbiUgIjAyDOszNp5z1dyV8Zu/bEmFj3+Uw/JID+IneZCtk/HKrPldwv+tAbSnL2+LTmQhcdfk3GZGRh/EcAyHB+PkswIoxP7p7XoQLt10fdYYpzPur4Mo45gH/RE9ybhpxfasAj7411w== git@ip"
      ];
      extraArgs.passwordFile = config.sops.secrets.portfwd_guest_password.path;
    })

  ];

}
