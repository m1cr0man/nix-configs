# Nix Configurations

Used to deploy m1cr0man.com primarily

## Using this repo in your own flakes

Everything in this repo is reusable, you don't have to fork
it! All [modules](./modules) are exported under the `nixosModules`
flake output keyed by their path.
For example, `m1cr0manFlake.nixosModules.sysconfig.zfs`.

## Secrets using Age, sops and sops-nix

Age is a simple program to encrypt/decrypt files.

sops is an encypted file editor supporting age (like ansible-vault)
and manages using multiple keys to encrypt/decrypt.

sops-nix provides a way to load sops encrypted config
files into Nix.

### Using the VS Code plugin to edit secrets

Simply open one of the files in [secrets](./secrets) in VS Code.
It will open a temporary decrypted file, and close it when you
close the file.

### Using the CLI to edit secrets

Type `sops secrets/filename.yaml`

### Adding a new admin key

You can generate one from your SSH key.
This is recommended - you are probably already
keeping your SSH key safe (right?), so you can regenerate
your age key from it if you ever lose it.

```bash
# Optional: If your key has a passphrase, copy it and remove the pwd first
# ssh-to-age can't prompt for password.
cp ~/.ssh/id_ed25519 ~/
ssh-keygen -p -N "" -f ~/id_ed25519
ssh-to-age -private-key -i ~/id_ed25519 >  ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
# Output is the entry to add to .sops.yml
```

### Adding a new host key

Again, you can use the host's sshd host key to build
an age key.

```bash
sudo cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# Output is the entry to add to .sops.yaml
# Also update relevant secret files
sops updatekeys modules/secrets/shared.yaml
sops updatekeys hosts/$HOSTNAME/secrets.yaml
```

### Launching MicroVMs

Example running the kube-master VM.

```bash
sudo microvm -f $(pwd) -c kube-master
```
