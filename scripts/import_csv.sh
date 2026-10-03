#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

CSV_FILE="${1:-}"
if [ -z "$CSV_FILE" ] || [ ! -f "$CSV_FILE" ]; then
    echo "Usage : $0 <fichier.csv>" >&2
    exit 1
fi

source .env
DB_CONTAINER="dolibarr_db"

if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}\$"; then
    echo "Erreur : le conteneur ${DB_CONTAINER} n'est pas démarré." >&2
    exit 1
fi

echo "=== Import de $CSV_FILE dans ${DB_NAME}.llx_societe ==="
LINE_NUM=1
IMPORTED=0
SKIPPED=0
esc() { printf '%s' "$1" | sed "s/'/''/g"; }

while IFS=',' read -r nom address zip town phone email statut client fournisseur; do
    LINE_NUM=$((LINE_NUM + 1))
    if [ -z "$nom" ]; then
        echo "  [ligne $LINE_NUM] ignorée : 'nom' vide"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    statut="${statut:-1}"
    client="${client:-0}"
    fournisseur="${fournisseur:-0}"
    SQL="INSERT INTO llx_societe (nom, entity, status, client, fournisseur, address, zip, town, phone, email, datec) VALUES ('$(esc "$nom")', 1, ${statut}, ${client}, ${fournisseur}, '$(esc "$address")', '$(esc "$zip")', '$(esc "$town")', '$(esc "$phone")', '$(esc "$email")', NOW());"
    docker exec "$DB_CONTAINER" mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "$SQL"
    IMPORTED=$((IMPORTED + 1))
    echo "  [ligne $LINE_NUM] importée : $nom"
done < <(tail -n +2 "$CSV_FILE")

echo "=== Import terminé : $IMPORTED insérées, $SKIPPED ignorées ==="
