FROM postgis/postgis:13-master

ENV WAL_G_VERSION v0.2.19

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq && apt-get install -qqy wget liblzo2-dev postgresql-${PG_MAJOR}-periods \
    && wget https://github.com/wal-g/wal-g/releases/download/$WAL_G_VERSION/wal-g.linux-amd64.tar.gz \
    && tar -zxvf wal-g.linux-amd64.tar.gz && mv wal-g /usr/local/bin/ && chmod a+x /usr/local/bin/wal-g \
    && rm wal-g.linux-amd64.tar.gz \
    && apt-get purge -y wget && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ADD scripts  /scripts
RUN chmod +x /scripts/*.sh

ENV PGHOST=/var/run/postgresql
ENV PGUSER=$POSTGRES_USER
ENV PGPASSWORD=$POSTGRES_PASSWORD


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
