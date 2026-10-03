#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"
source .env

BACKUP_DIR="${BACKUP_DIR:-./backups}"
DB_CONTAINER="dolibarr_db"
APP_CONTAINER="dolibarr_app"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
WORKDIR="$(mktemp -d)"
mkdir -p "$BACKUP_DIR"

echo "=== Dump SQL ==="
docker exec "$DB_CONTAINER" mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" --single-transaction "${DB_NAME}" > "${WORKDIR}/dolibarr_db.sql"

echo "=== Archive des documents ==="
docker run --rm --volumes-from "$APP_CONTAINER" -v "${WORKDIR}:/backup" alpine tar czf /backup/dolibarr_documents.tar.gz -C /var/www documents

FINAL_ARCHIVE="${BACKUP_DIR}/dolibarr_backup_${TIMESTAMP}.tar.gz"
tar czf "$FINAL_ARCHIVE" -C "$WORKDIR" dolibarr_db.sql dolibarr_documents.tar.gz
rm -rf "$WORKDIR"

echo "=== Sauvegarde terminée : $FINAL_ARCHIVE ==="
du -h "$FINAL_ARCHIVE"
