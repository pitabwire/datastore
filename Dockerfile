FROM postgis/postgis:14-3.1

LABEL org.opencontainers.image.source=https://github.com/pitabwire/datastore

ENV WAL_G_VERSION v1.1

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq && apt-get install -qqy wget liblzo2-dev postgresql-${PG_MAJOR}-periods \
    && wget https://github.com/wal-g/wal-g/releases/download/$WAL_G_VERSION/wal-g-pg-ubuntu-20.04-amd64.tar.gz \
    && tar -zxvf wal-g-pg-ubuntu-20.04-amd64.tar.gz && mv wal-g /usr/local/bin/ && chmod a+x /usr/local/bin/wal-g \
    && rm wal-g-pg-ubuntu-20.04-amd64.tar.gz \
    && apt-get purge -y wget && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*


COPY recovery.conf /etc/
COPY datastore-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/datastore-entrypoint.sh

ENV PGHOST=/var/run/postgresql
ENV PGUSER=$POSTGRES_USER
ENV PGPASSWORD=$POSTGRES_PASSWORD

# WALG_GS_PREFIX: 'gs://backup-bucket/walg-folder'
# GOOGLE_APPLICATION_CREDENTIALS: '/serviceAccountKey.json'

# Do a basebackup of postgres every day
# RUN echo "@daily wal-g backup-push $PGDATA" | crontab -
# Use following command to append job to cron
# CMD (crontab -l && echo "@daily bash ~/make_basebackup.sh") | crontab -

# By setting this env to TRUE the system will boot up by attempting a
# recovery from the latest base backup
ENV PERFORM_RECOVERY "FALSE"


ENTRYPOINT ["datastore-entrypoint.sh"]
