#!/bin/bash
set -e

# This script wraps the MongoDB entrypoint to restrict mongod to run on a single socket
# using taskset and numactl for CPU affinity and NUMA node binding

TOTAL_CPUS=$(nproc)
NUMA_NODES=$(numactl --hardware | grep "available:" | awk '{print $2}')
if [ "$NUMA_NODES" -gt 0 ]; then
    CPUS_PER_SOCKET=$((TOTAL_CPUS / NUMA_NODES))
else
    CPUS_PER_SOCKET=$TOTAL_CPUS
fi

SOCKET_NUM=${MONGODB_SOCKET:-0}
START_CPU=$((SOCKET_NUM * CPUS_PER_SOCKET))
END_CPU=$((START_CPU + CPUS_PER_SOCKET - 1))

echo "MongoDB: Restricting to socket $SOCKET_NUM (NUMA node $SOCKET_NUM)"
echo "MongoDB: Using CPUs $START_CPU-$END_CPU"
echo "MongoDB: Total CPUs: $TOTAL_CPUS, NUMA nodes: $NUMA_NODES, CPUs per socket: $CPUS_PER_SOCKET"

export MONGODB_CPU_AFFINITY="$START_CPU-$END_CPU"
export MONGODB_NUMA_NODE="$SOCKET_NUM"

if [ "$1" = 'mongod' ] || [ "$1" = 'mongo' ] || [ -z "$1" ]; then
    exec numactl --cpunodebind=$SOCKET_NUM --membind=$SOCKET_NUM \
         taskset -c $START_CPU-$END_CPU \
         /usr/local/bin/docker-entrypoint.sh "$@"
else
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi
