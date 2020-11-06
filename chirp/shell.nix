{ pkgs ? import <nixpkgs> { } }:

# https://ejpcmac.net/blog/using-nix-in-elixir-projects/
with pkgs;

let
  inherit (lib) optional optionals;

  elixir = beam.packages.erlangR21.elixir_1_7;
  nodejs = nodejs-10_x;
  postgresql = postgresql_10;

in mkShell {
  buildInputs = [ elixir nodejs git postgresql ]
    ++ optional stdenv.isLinux inotify-tools # For file_system on Linux.
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      # For file_system on macOS.
      CoreFoundation
      CoreServices
    ]);

  # Put the PostgreSQL databases in the project diretory.
  shellHook = ''
    export PGDATA=$PWD/postgres_data
    export PGHOST=$PWD/postgres
    export LOG_PATH=$PWD/postgres/LOG
    export PGDATABASE=postgres

    export DATABASE_URL="postgresql:///postgres?host=$PGHOST"
    if [ ! -d $PGHOST ]; then
      mkdir -p $PGHOST
    fi
    if [ ! -d $PGDATA ]; then
      echo 'Initializing postgresql database...'
      initdb $PGDATA --auth=trust >/dev/null
    fi
    pg_ctl -l $LOG_PATH -o "-c unix_socket_directories=$PGHOST" start
  '';
}
# -c listen_addresses=

# initdb - D .tmp/chirp_dev
# pg_ctl - D .tmp/chirp_dev - l logfile
# - o "--unix_socket_directories='$PWD'" start
# createdb chirp_dev

# export DATABASE_URL="postgresql:///postgres?host=$PGHOST"
# if [ ! -d $PGHOST ]; then
#    mkdir -p $PGHOST
# fi
# if [ ! -d $PGDATA ]; then
#    echo 'Initializing postgresql database...'
#    initdb $PGDATA --auth=trust >/dev/null
#    fi
# pg_ctl start -l $LOG_PATH -o "-c listen_addresses= -c unix_socket_directories=$PGHOST"

# CREATE USER Postgres with password 'Phoenix';
# https://mgdm.net/weblog/postgresql-in-a-nix-shell/

# another way of working with a local postgres instance is here: https://ejpcmac.net/blog/using-nix-in-elixir-projects/
