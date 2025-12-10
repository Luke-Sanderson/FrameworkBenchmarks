FROM postgres:15-bullseye

ENV POSTGRES_USER=benchmarkdbuser
ENV POSTGRES_PASSWORD=benchmarkdbpass
ENV POSTGRES_DB=hello_world

ENV POSTGRES_HOST_AUTH_METHOD=md5
ENV POSTGRES_INITDB_ARGS=--auth-host=md5
ENV PGDATA=/ssd/postgresql

COPY postgresql-min.conf /tmp/postgresql.conf

COPY create-postgres.sql /docker-entrypoint-initdb.d/
COPY config.sh /docker-entrypoint-initdb.d/

COPY 60-postgresql-shm.conf /etc/sysctl.d/60-postgresql-shm.conf

# Install numactl for NUMA node binding
RUN apt-get update && apt-get install -y numactl && rm -rf /var/lib/apt/lists/*

# Copy custom entrypoint that restricts PostgreSQL to a single socket
COPY postgres-entrypoint.sh /usr/local/bin/postgres-entrypoint.sh
RUN chmod +x /usr/local/bin/postgres-entrypoint.sh

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/postgres-entrypoint.sh"]
CMD ["postgres"]

