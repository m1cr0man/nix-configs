# For all domains

- Ensure CF SSL setting is `Full (strict)`
- Set up proxied records for root and www.
- Create nix configs
- Chown the home dir
- Set ACME server to prod

# Restoring mysql

- Extract the mysqldump.sql somewhere
- Run `mysql` in that directory
- `source mysqldump.sql;`
- Remove the extracted sql

# Restoring postgresql

- Extract the postgresql.sql to ~postgres/
- Run `sudo -u postgres psql -f postgresql.sql postgres`
- Remove the extracted sql

# Renaming mysql databases

```sql
SELECT CONCAT('RENAME TABLE ',table_schema,'.`',table_name,
    '` TO ','new_name.`',table_name,'`;')
FROM information_schema.TABLES
WHERE table_schema LIKE 'old_name';
/* That command just generates the commands. Copy into VSCode then run in the shell.
  Also drop unused users.
*/
DROP USER old_username@localhost;
DROP DATABASE old_name;
```

# Renaming postgres databases

```sql
ALTER DATABASE $old_name RENAME TO $new_name;
REASSIGN OWNED BY $old_username TO $new_username;
-- Restart connection and connect into db $new_name
REASSIGN OWNED BY $old_username TO $new_username;
DROP ROLE $old_username;
```

New host will be `/run/postgresql`.

# For wordpress sites

- Ensure mysql is restored already
- BEFORE nixos-rebuild Ensure new username doesn't exist in mysql by issuing a DROP USER
- Set `wordpress = true` on the mkDomain
- Perform database table rename

- Update wp-config.php
  - Set DB_HOST to `localhost:/run/mysqld/mysqld.sock`
  - Set DB_NAME + DB_USER to the username
  - Remove DB_PASSWORD

# For Joomla sites

- Update configuration.php
  - set $dbtype to mysqli
  - set $host to `localhost:/run/mysqld/mysqld.sock`
  - set $user + $db to the username
  - Clear $password
  - OPTIONAL set $session_handler to none if session errors occur
