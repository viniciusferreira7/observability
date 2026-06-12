#!/bin/sh
# Bootstraps a single-node Garage cluster for the observability stack:
# assigns a layout, imports the application S3 key, and creates the buckets
# used by Loki, Tempo and Mimir. Safe to re-run (idempotent).
set -eu

CONF="/etc/garage.toml"
BUCKETS="loki-data loki-ruler tempo mimir"

echo "[garage-init] waiting for garage node to be reachable..."
until garage -c "$CONF" status >/dev/null 2>&1; do
  sleep 2
done

NODE_ID="$(garage -c "$CONF" node id -q | cut -d@ -f1)"
# `layout show` prints the 16-char short id, so match on that.
SHORT_ID="$(echo "$NODE_ID" | cut -c1-16)"
echo "[garage-init] node id: $NODE_ID"

# Assign a cluster layout only if this node has no role yet (layout persists
# in the metadata volume, so this is skipped on restarts).
if ! garage -c "$CONF" layout show | grep -q "$SHORT_ID"; then
  echo "[garage-init] assigning cluster layout..."
  garage -c "$CONF" layout assign -z dc1 -c 1G "$NODE_ID"
  garage -c "$CONF" layout apply --version 1
fi

echo "[garage-init] importing application access key..."
garage -c "$CONF" key import --yes -n app "$GARAGE_ACCESS_KEY" "$GARAGE_SECRET_KEY" \
  || echo "[garage-init] key already present, skipping import"

for b in $BUCKETS; do
  echo "[garage-init] ensuring bucket '$b'..."
  garage -c "$CONF" bucket create "$b" 2>/dev/null || true
  garage -c "$CONF" bucket allow --read --write --owner "$b" --key "$GARAGE_ACCESS_KEY"
done

echo "[garage-init] bootstrap complete."
