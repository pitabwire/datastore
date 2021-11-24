#!/bin/bash

source /usr/local/bin/docker-entrypoint.sh

docker_setup_env
docker_create_db_directories

if [ "$(id -u)" = '0' ]; then
  # then restart script as postgres user
  exec gosu postgres "$BASH_SOURCE" "$@"
fi

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "The postgresql data directory $PGDATA does not exist."

  if [ -n "${RUN_AS_REPLICA}"  ]; then

    echo " Container identifies a secondary instance hence starting from base backup"
    export PGPASSWORD=${REPLICATION_PASSWORD}
    pg_basebackup -h "${REPLICATION_HOST}" -U replicator -p 5432 -D "${PGDATA}" -S "${REPLICATION_SLOT}" -Fp -Xs -R
    unset PGPASSWORD
    if [ $? -ne 0 ]; then
      echo "  Failed to execute pg_basebackup."
      exit 1
    fi

  else

    echo " Container identifies as the primary hence starting it normally"
    if [ $PERFORM_RECOVERY = "TRUE" ]; then

      echo " Instance starting from a backup as configured"
      # Restore base backup.
      # Will create a new Database Cluster.
      wal-g backup-fetch "$PGDATA" LATEST

      # Move recovery.conf to cluster to tell postgres where to fetch WAL from.
      mv /etc/recovery.conf $PGDATA

      chown -R postgres:postgres $PGDATA
      chmod 700 $PGDATA
    else

      docker_init_database_dir
      export PGPASSWORD=${POSTGRES_PASSWORD}
      docker_temp_server_start "$@"
      docker_setup_db
      docker_process_init_files /docker-entrypoint-initdb.d/*
      docker_temp_server_stop
      unset PGPASSWORD

    fi

  fi

  echo -e "local all all  trust\nhost all all all $POSTGRES_HOST_AUTH_METHOD\nhostssl all all all $POSTGRES_HOST_AUTH_METHOD" > "$PGDATA/pg_hba.conf"
fi

exec "$@"
