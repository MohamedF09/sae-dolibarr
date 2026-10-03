#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

ARCHIVE="${1:-}"
if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
    echo "Usage : $0 <archive.tar.gz>" >&2
    exit 1
fi

source .env
DB_CONTAINER="dolibarr_db"
APP_CONTAINER="dolibarr_app"
WORKDIR="$(mktemp -d)"

if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}\$"; then
    echo "Erreur : lance d'abord ./install.sh" >&2
    exit 1
fi

echo "=== Extraction ==="
tar xzf "$ARCHIVE" -C "$WORKDIR"

echo "=== Restauration base de données ==="
docker exec -i "$DB_CONTAINER" mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${WORKDIR}/dolibarr_db.sql"

echo "=== Restauration documents ==="
docker cp "${WORKDIR}/dolibarr_documents.tar.gz" "${APP_CONTAINER}:/tmp/dolibarr_documents.tar.gz"
docker exec "$APP_CONTAINER" sh -c "rm -rf /var/www/documents/* && tar xzf /tmp/dolibarr_documents.tar.gz -C /var/www && rm /tmp/dolibarr_documents.tar.gz"

rm -rf "$WORKDIR"
echo "=== Restauration terminée ==="
