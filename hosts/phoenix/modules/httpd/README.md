# Web Hosting Management

## Setting up SFTP access

1. Create an SSH key for the user and grant access. Run this on Phoenix.

```sh
# Change jdoe to the customer name
sudo -su jdoe
cd ~
ssh-keygen -t ed25519
# Accept default path
# Enter a password
# Confirm password
cp -av .ssh/id_ed25519.pub .ssh/authorized_keys
# Leave jdoe
exit
# Copy the key to your own home
cd
sudo cp -a ~jdoe/.ssh/id_ed25519 id_ed25519_jdoe.pem
sudo chown $USER:$USER id_ed25519_jdoe.pem
# Convert the key to PPK using puttygen.
nix shell nixpkgs#putty
puttygen id_ed25519_jdoe.pem -o id_ed25519_jdoe.ppk
```

2. Download the SSH key. Run this on your local PC.

```sh
# Copy to D drive
scp phoenix:id_ed25519_jdoe.pem D:\
scp phoenix:id_ed25519_jdoe.ppk D:\
```

3. Send both the PEM and PPK SSH key and password to the customer.
  The credentials will be:

  - User: jdoe
  - Password: ***
  - Home: /home/jdoe
  - Web root: /home/jdoe/public_html
