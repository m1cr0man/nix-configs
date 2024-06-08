# Email container

Runs Simple NixOS Mailserver and serves mail for multiple domains.

## Recovering single emails from ZFS snapshots

You must configure SMTP in ~/.mutt/muttrc first. Example for STARTTLS:

```bash
set realname = "J. Doe"
set from = "jdoe@example.com"
set use_from = yes
set envelope_from = yes

set smtp_url = "smtp://jdoe@example.com@mail.example.com:587/"
set smtp_pass = "123pwd"
set ssl_starttls = yes
set ssl_force_tls = yes
set smtp_authenticators="plain"
```

Mount the snapshot and open mutt:

```bash
mkdir mnt
mount -t zfs -o ro $SNAPSHOT_NAME
cd mnt/mailboxes/$DOMAIN/$USER[/sub-mailbox]
nix run nixpkgs#mutt -- -R -f .
```

You can hit "no" to creating `$USER/Mail`.

Within Mutt, find the email then press `b` to "bounce" the mail.
You will be prompted for a `To:` address, and then it will
forward the mail via SMTP.
