#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DB_HOST:-}" || -z "${DB_PORT:-}" || -z "${DB_USER:-}" || -z "${PRIMARY_DB:-}" || -z "${SECONDARY_DB:-}" ]]; then
  echo "Missing required environment variables for MySQL bootstrap" >&2
  exit 1
fi

echo "[bootstrap] Starting MySQL bootstrap for host=${DB_HOST} port=${DB_PORT} primary_db=${PRIMARY_DB}"
if [[ -n "${FORCE_TOKEN:-}" ]]; then
  echo "[bootstrap] Force-run token: ${FORCE_TOKEN}"
fi

echo "[bootstrap] Waiting for MySQL connectivity..."
for attempt in {1..30}; do
  if mysql --connect-timeout=10 -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -e "SELECT 1" >/dev/null 2>&1; then
    echo "[bootstrap] MySQL is reachable"
    break
  fi

  if [[ "$attempt" -eq 30 ]]; then
    echo "[bootstrap] Unable to connect to MySQL after 30 attempts" >&2
    exit 1
  fi

  sleep 10
done

mysql --connect-timeout=30 \
  -h "$DB_HOST" \
  -P "$DB_PORT" \
  -u "$DB_USER" \
  -e "CREATE DATABASE IF NOT EXISTS \`$SECONDARY_DB\`;"

echo "[bootstrap] Ensured secondary database exists: ${SECONDARY_DB}"

if [[ -n "${DUMP_FILE:-}" ]]; then
  if [[ ! -f "$DUMP_FILE" ]]; then
    echo "Dump file not found: $DUMP_FILE" >&2
    exit 1
  fi

  echo "[bootstrap] Importing dump file '${DUMP_FILE}' into database '${PRIMARY_DB}'"

  mysql --connect-timeout=30 \
    -h "$DB_HOST" \
    -P "$DB_PORT" \
    -u "$DB_USER" \
    "$PRIMARY_DB" < "$DUMP_FILE"

  echo "[bootstrap] Dump import completed successfully"
else
  echo "[bootstrap] DUMP_FILE is empty; skipping import"
fi
