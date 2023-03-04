{ writeScriptBin, postgresql_15, postgresql_13, newPostgresPkg ? postgresql_15, oldPostgresPkg ? postgresql_13 }:
let
  # XXX specify the postgresql package you'd like to upgrade to.
  # Do not forget to list the extensions you need.
  newPostgres = newPostgresPkg.withPackages (pp: [
    pp.postgis
  ]);
in writeScriptBin "upgrade-pg-cluster" ''
  if [ -z "$1" ]; then
    echo "Usage: $0 olddata_dir"
    exit 1
  fi

  set -euxo pipefail

  # XXX it's perhaps advisable to stop all services that depend on postgresql
  systemctl stop postgresql

  export OLDDATA="$1"

  export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

  export NEWBIN="${newPostgres}/bin"

  export OLDBIN="${oldPostgresPkg}/bin"

  install -d -m 0700 -o postgres -g postgres "$NEWDATA"
  cd "$NEWDATA"
  sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

  sudo -u postgres $NEWBIN/pg_upgrade \
    --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
    --old-bindir $OLDBIN --new-bindir $NEWBIN \
    "''${@:2}"
''
