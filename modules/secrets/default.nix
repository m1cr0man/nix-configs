# Shared secrets module
# Anything that doesn't need to be host-specific can be declared here.
# The path must be set as sops.defaultSopsFile is set in lib/output.nix
# in mkConfiguration to configure per-host secrets files.
{ self, config, ... }:
let
  path = ./shared.yaml;
in
{
  # Use SSH host key as SOPS key
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Use the host-specific sops secrets by default
  sops.defaultSopsFile = "${self}/${config.m1cr0man.instanceType}s/${config.networking.hostName}/secrets.yaml";

  sops.secrets.acme_cloudflare_env.sopsFile = path;
  sops.secrets.generic_htpasswd.sopsFile = path;
  sops.secrets.minecraft_rcon_env.sopsFile = path;
  sops.secrets.minio_credentials_env.sopsFile = path;
  sops.secrets.spice_password_env.sopsFile = path;
  sops.secrets.spice_password.sopsFile = path;
  sops.secrets.matrix_synapse_database_password.sopsFile = path;
  sops.secrets.matrix_synapse_database_hashed_password.sopsFile = path;
  sops.secrets.nextcloud_database_password.sopsFile = path;
  sops.secrets.nextcloud_database_hashed_password.sopsFile = path;
  sops.secrets.rainloop_database_password.sopsFile = path;
  sops.secrets.rainloop_database_hashed_password.sopsFile = path;
  sops.secrets.headscale_database_password.sopsFile = path;
  sops.secrets.headscale_database_hashed_password.sopsFile = path;
  sops.secrets.ferretdb_database_password.sopsFile = path;
  sops.secrets.ferretdb_database_hashed_password.sopsFile = path;
  sops.secrets.matrix_synapse_db_settings.sopsFile = path;
  sops.secrets.doveadm_password.sopsFile = path;
  sops.secrets.sysmail_password.sopsFile = path;
}
