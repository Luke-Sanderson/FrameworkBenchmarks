#!/bin/bash
set -e

echo "PostgreSQL: Restricting to socket ${POSTGRES_SOCKET:-0} (NUMA node ${POSTGRES_SOCKET:-0})"

TOTAL_CPUS=$(nproc)
NUMA_NODES=$(numactl --hardware | grep "available:" | awk '{print $2}')

if [ "$NUMA_NODES" -gt 0 ]; then
    CPUS_PER_SOCKET=$((TOTAL_CPUS / NUMA_NODES))
else
    CPUS_PER_SOCKET=$TOTAL_CPUS
fi

SOCKET_NUM=${POSTGRES_SOCKET:-0}
START_CPU=$((SOCKET_NUM * CPUS_PER_SOCKET))
END_CPU=$((START_CPU + CPUS_PER_SOCKET - 1))

echo "PostgreSQL: Using CPUs $START_CPU-$END_CPU"
echo "PostgreSQL: Total CPUs: $TOTAL_CPUS, NUMA nodes: $NUMA_NODES, CPUs per socket: $CPUS_PER_SOCKET"

export POSTGRES_CPU_AFFINITY="$START_CPU-$END_CPU"
export POSTGRES_NUMA_NODE="$SOCKET_NUM"

if [ "$1" = 'postgres' ]; then
    exec numactl --cpunodebind=$SOCKET_NUM --membind=$SOCKET_NUM \
         taskset -c $START_CPU-$END_CPU \
         /usr/local/bin/docker-entrypoint.sh "$@"
else
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi

