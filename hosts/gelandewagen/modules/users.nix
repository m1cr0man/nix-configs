{ config, pkgs, lib, ... }:
let
  rootKeys = config.users.users.root.openssh.authorizedKeys.keys;

  mkNormalUser = name: { description ? "Manged by NixOS Config", keys ? [ ], group ? name, home ? "/home/${name}", extraArgs ? { } }: {
    "${name}" = {
      inherit name description group home;
      openssh.authorizedKeys.keys = rootKeys ++ keys;
      createHome = true;
      isSystemUser = false;
      isNormalUser = true;
      useDefaultShell = true;
    } // extraArgs;
  };

in
{
  users.groups = {
    breogan = { };
    anders = { };
    mcadmins = { };
    lucas = { };
    conor = { };
  };

  sops.secrets.portfwd_guest_password.neededForUsers = true;

  users.users = lib.mkMerge [
    (mkNormalUser "anders" {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuW9Vc1zz3qA++TpqLb6jTBx2ZfejO0uqrYt/tmGaEM ed25519-key-20210126"
      ];
    })

    (mkNormalUser "breogan" {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIeiNkZ53utCm/d9a/m46xe00OTlRnRlrgEoiRmpW1j ed25519-key-20200418"
      ];
    })

    (mkNormalUser "conor" {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUlcCjTDPA9E4Bj04kdojvsjNnXXWKhJdmrum94zUdm Conor@LAPTOP-VA4JS3RE"
      ];
      extraArgs.packages = with pkgs; [
        nodejs-14_x
      ];
    })

    (mkNormalUser "gmod" {
      description = "Garrys mod";
      group = "users";
      extraArgs = {
        extraGroups = [ "wheel" ];
        uid = 1000;
      };
    })

    (mkNormalUser "lucas" {
      extraArgs.extraGroups = [ "wheel" ];
    })

    (mkNormalUser "mcadmins" {
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMTwoP357Z13kPk3jRc8fzSCQCIYrIe/X/a4rtKq/sPE+6ydUsXXZdcB9PvFNElDmTJGk0IoaJ6gjfjJFhzRMJvg4IKJ3mFWnkJ2FBdn+rB9CWxzx8VRZfN5Tj3BmQ/olgvxHlyI+Qh1+ceBCUH1PzNhAXTJ8uSc1rIWspunbbOU3kjW7nkf3SYCRIdHkFZXr3sf7jhw0EVvFUqfWMEl3uiEbFXzd3Hq1rFxAhvf0145ydnH/gBUyxuTP4tQDSbB3yfs8wSTRhXVDqYVz6+BKdRk67SsdY50+GR1Vp2Pd/tdmJlhu7yYyn6IPY8LIx3SGWPlk5prckDvA3I4ppdIz0ZcSgqgi9fYDmDWisaWwjPJzGlTUHLnzgxehCqrwj0qQC+k5PS6Epxq1OCyBlJcSUGgCQypLZMEOuqqf5G6ouhpvzBoDOc131Ih5Rj0zH/5r+ke+GGifoLRtbHBf2TdFjnNGjlf2XANLwHhICs3r7CPr6Kd+uQZzzApCB+wx1m8hBtax86/XqZUOr70tbbUiZvZpWzJMo7jsozsUnWfN4NBqzsyZ6/nWzpCYSXxiG8xGIptFBHr/2EsY3QaoJ8ncXdEt5d1WgqxQ3cepW+n+KYcavymy2ywO1Mij2Dwt7SobUMhkcrfVcxyFehozQAOZkZqL3ByGAaqdghpkIwn0MCQ== sailslickcode"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9ajmos3wSH3igGDzNXTC8Gpew2XfFWE17czqXXJMBs dvxl@synckey-apd"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL8j3uGq7UuFBvFrJPAzgkiaushzYnjyHYQKeQ48fgd Drumsy"
      ];
    })

    (mkNormalUser "portfwd-guest" {
      home = "/var/empty";
      group = "nogroup";
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtXDL7LWBiySe4YZmosFxqzjxjcROtmse22+HFShD4L7bjpqWDkIy7ynTAn/EzizVAT2UFs2z2QObJBsaxObPMdYLpAnVW2sLKh40AhsveYlxiXhVbpfMqIZ6lqtUOMqSN3ql7eUwqWMnWtBz4yl5XwLIoNmnT20XDjNJzoGk+VOTNedldDZEM1oHOw+owtAr1k2sBu2dStXbiUgIjAyDOszNp5z1dyV8Zu/bEmFj3+Uw/JID+IneZCtk/HKrPldwv+tAbSnL2+LTmQhcdfk3GZGRh/EcAyHB+PkswIoxP7p7XoQLt10fdYYpzPur4Mo45gH/RE9ybhpxfasAj7411w== git@ip"
      ];
      extraArgs.passwordFile = config.sops.secrets.portfwd_guest_password.path;
    })

  ];

}