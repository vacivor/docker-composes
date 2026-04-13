#!/bin/sh

set -eu

ANNOUNCE_IP="${REDIS_CLUSTER_ANNOUNCE_IP:-127.0.0.1}"
PORTS="7001 7002 7003 7004 7005 7006"

wait_for_node() {
  port="$1"
  until redis-cli -h 127.0.0.1 -p "$port" ping >/dev/null 2>&1; do
    sleep 1
  done
}

for port in $PORTS; do
  wait_for_node "$port"
done

if redis-cli -h 127.0.0.1 -p 7001 cluster info 2>/dev/null | grep -q 'cluster_state:ok'; then
  echo "Redis Cluster is already initialized."
  exit 0
fi

yes yes | redis-cli --cluster create \
  "${ANNOUNCE_IP}:7001" \
  "${ANNOUNCE_IP}:7002" \
  "${ANNOUNCE_IP}:7003" \
  "${ANNOUNCE_IP}:7004" \
  "${ANNOUNCE_IP}:7005" \
  "${ANNOUNCE_IP}:7006" \
  --cluster-replicas 1
