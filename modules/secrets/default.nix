# Shared secrets module
# Anything that doesn't need to be host-specific can be declared here.
# The path must be set as sops.defaultSopsFile is set in lib/output.nix
# in mkConfiguration to configure per-host secrets files.
let
  path = ./shared.yaml;
in
{
  sops.secrets.generic_htpasswd.sopsFile = path;
  sops.secrets.minecraft_rcon_env.sopsFile = path;
  sops.secrets.spice_password_env.sopsFile = path;
}
