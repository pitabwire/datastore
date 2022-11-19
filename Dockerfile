FROM netdata/wget as builder

ENV WAL_G_VERSION v2.0.1

RUN wget https://github.com/wal-g/wal-g/releases/download/$WAL_G_VERSION/wal-g-pg-ubuntu-20.04-amd64.tar.gz \
        && tar -zxvf wal-g-pg-ubuntu-20.04-amd64.tar.gz


FROM postgis/postgis:15-3.3

LABEL org.opencontainers.image.source=https://github.com/pitabwire/datastore

COPY --from=builder /wal-g-pg-ubuntu-20.04-amd64 /usr/local/bin/wal-g
RUN chmod a+x /usr/local/bin/wal-g

COPY datastore-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/datastore-entrypoint.sh

ENV PGHOST=/var/run/postgresql
ENV PGUSER=$POSTGRES_USER
ENV PGPASSWORD=$POSTGRES_PASSWORD

# By setting this env to TRUE the system will boot up by attempting a
# recovery from the latest base backup
ENV PERFORM_RECOVERY "FALSE"


ENTRYPOINT ["datastore-entrypoint.sh"]
