FROM mongo:6.0

# Install numactl for NUMA node binding
RUN apt-get update && apt-get install -y numactl && rm -rf /var/lib/apt/lists/*

ENV MONGO_INITDB_DATABASE=hello_world

# Copy initialization script
COPY create.js /docker-entrypoint-initdb.d/

# Copy custom entrypoint that restricts MongoDB to a single socket
COPY mongodb-entrypoint.sh /usr/local/bin/mongodb-entrypoint.sh
RUN chmod +x /usr/local/bin/mongodb-entrypoint.sh

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/mongodb-entrypoint.sh"]
CMD ["mongod"]
