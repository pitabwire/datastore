#!/bin/bash

if [ $PERFORM_RECOVERY = "TRUE" ];
then
    # Restore base backup.
    # Will create a new Database Cluster.
    wal-g backup-fetch "$PGDATA" LATEST

    # Move recovery.conf to cluster to tell postgres where to fetch WAL from.
    mv /scripts/recovery.conf $PGDATA

    chown -R postgres:postgres $PGDATA
    chmod 700 $PGDATA

fi

# Execute command given in Dockerfile ("docker-entrypoint.sh", "postgres").
exec "$@"
