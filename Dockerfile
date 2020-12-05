FROM postgis/postgis:13-3.0

ENV WAL_G_VERSION v0.2.15

RUN apt-get update && apt-get install -y wget liblzo2-dev postgresql-${PG_MAJOR}-periods \
    && wget https://github.com/wal-g/wal-g/releases/download/$WAL_G_VERSION/wal-g.linux-amd64.tar.gz \
    && tar -zxvf wal-g.linux-amd64.tar.gz && mv wal-g /usr/local/bin/ && chmod a+x /usr/local/bin/wal-g \
    && apt-get purge -y wget && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ADD scripts  /scripts
RUN chmod +x /scripts/*.sh

VOLUME /var/lib/postgresql/backup:z
ENV WALG_FILE_PREFIX /var/lib/postgresql/backup

# ENV WALG_SSH_PREFIX ssh://10.0.0.5/postgresql/backup
# ENV SSH_PORT 22
# ENV SSH_USERNAME postgresql
# ENV SSH_PASSWORD backups

# WALG_GS_PREFIX: 'gs://backup-bucket/walg-folder'
# GOOGLE_APPLICATION_CREDENTIALS: '/serviceAccountKey.json'

# Do a basebackup of postgres every day
# RUN echo "@daily wal-g backup-push $PGDATA" | crontab -
# Use following command to append job to cron
# CMD (crontab -l && echo "@daily bash ~/make_basebackup.sh") | crontab -

# By setting this env to TRUE the system will boot up by attempting a
# recovery from the latest base backup
ENV PERFORM_RECOVERY "FALSE"

# Restore base backup,
# set user permissions and
# copy recovery.conf into data cluster.
ENTRYPOINT ["/scripts/init_recovery.sh"]

# Run default Postgres/PostGIS entrypoint and
# start Postgres.
CMD ["docker-entrypoint.sh", "postgres", "-c","max_connections=100", "-c", "shared_buffers=512MB", \
     "-c","archive_mode=on", "-c","archive_timeout=60", "-c","archive_command=\"wal-g wal-push %p\""]
