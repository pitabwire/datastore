
**datastore**

 A postgresql image with a few commonly used extensions. 
 The image utilizes 
    1. wal-g for backup operations
    2. reuses the built entrypoint to enable master secondary operations
 
To run directly use :

    docker run --name datastorex -e POSTGRES_PASSWORD=secrets postgres -c shared_buffers=256MB -c max_connections=200 -c ssl=on -c ssl_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem -c ssl_key_file=/etc/ssl/private/ssl-cert-snakeoil.key

To run with docker compose use :

    service:
          datastore:
            image: ghcr.io/pitabwire/datastore:v15.0.0
            restart: unless-stopped
            security_opt:
              - no-new-privileges:true
            command:
              - "postgres"
              - "-c"
              - "max_connections=50"
              - "-c"
              - "shared_buffers=256MB"
              - "-c"
              - "ssl=on"
              - "-c"
              - "ssl_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem"
              - "-c"
              - "ssl_key_file=/etc/ssl/private/ssl-cert-snakeoil.key"
            environment:
              POSTGRES_PASSWORD: "st@w!"
            ports:
              - 5423:5432
            volumes:
              - /var/lib/stawi/postgresql/data:/var/lib/postgresql/data
              - ./docker-db-init.sql:/docker-entrypoint-initdb.d/init.sql


When restoring from backup add command :

    restore_command = 'wal-g wal-fetch "%f" "%p"'

For automatic backup use :


    # WALG_GS_PREFIX: 'gs://backup-bucket/walg-folder'
    # GOOGLE_APPLICATION_CREDENTIALS: '/serviceAccountKey.json'
    
    # Do a basebackup of postgres every day
    # RUN echo "@daily wal-g backup-push $PGDATA" | crontab -
    # Use following command to append job to cron
    # CMD (crontab -l && echo "@daily bash ~/make_basebackup.sh") | crontab -
