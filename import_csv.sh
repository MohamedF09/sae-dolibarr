#!/usr/bin/env bash
#
# import_csv.sh - Import direct des Tiers dans la base Dolibarr (court-circuite l'UI web)
#
# Usage : ./import_csv.sh <fichier.csv> <db_user> <db_name>

set -euo pipefail

CSV_FILE="${1:-}"
DB_USER="${2:-dolibarr}"
DB_NAME="${3:-dolibarr}"

if [ -z "$CSV_FILE" ] || [ ! -f "$CSV_FILE" ]; then
    echo "Usage : $0 <fichier.csv> [db_user] [db_name]" >&2
    exit 1
fi

echo "=== Import de $CSV_FILE dans ${DB_NAME}.llx_societe (user: ${DB_USER}) ==="
echo "Mot de passe MySQL :"
read -rs DB_PASS
echo ""

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

    SQL="INSERT INTO llx_societe
        (nom, entity, status, client, fournisseur, address, zip, town, phone, email, datec)
        VALUES
        ('$(esc "$nom")', 1, ${statut}, ${client}, ${fournisseur}, '$(esc "$address")', '$(esc "$zip")', '$(esc "$town")', '$(esc "$phone")', '$(esc "$email")', NOW());"

    mysql -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "$SQL"

    IMPORTED=$((IMPORTED + 1))
    echo "  [ligne $LINE_NUM] importée : $nom (client=$client, fournisseur=$fournisseur)"
done < <(tail -n +2 "$CSV_FILE")

echo "=== Import terminé : $IMPORTED insérées, $SKIPPED ignorées ==="
