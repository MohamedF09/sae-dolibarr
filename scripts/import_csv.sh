#!/usr/bin/env bash
# Arrête immédiatement le script en cas d'erreur, de variable non définie ou d'échec dans un pipe
set -euo pipefail

# Récupération du répertoire où se trouve le script et positionnement à la racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# Vérification qu'un fichier CSV a bien été passé en argument et qu'il existe
CSV_FILE="${1:-}"
if [ -z "$CSV_FILE" ] || [ ! -f "$CSV_FILE" ]; then
    echo "Usage : $0 <fichier.csv>" >&2
    exit 1
fi

# Chargement des variables d'environnement (identifiants de base de données, nom de la BDD, etc.)
source .env
DB_CONTAINER="dolibarr_db"

# Vérification que le conteneur de la base de données est bien en cours d'exécution
if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}\$"; then
    echo "Erreur : le conteneur ${DB_CONTAINER} n'est pas démarré." >&2
    exit 1
fi

echo "=== Import de $CSV_FILE dans ${DB_NAME}.llx_societe ==="
LINE_NUM=1
IMPORTED=0
SKIPPED=0

# Fonction pour échapper les simples quotes (') afin d'éviter les erreurs de syntaxe SQL
esc() { printf '%s' "$1" | sed "s/'/''/g"; }

# Lecture du fichier CSV ligne par ligne en séparant les champs par des virgules
while IFS=',' read -r nom address zip town phone email statut client fournisseur; do
    LINE_NUM=$((LINE_NUM + 1))
    
    # Si le nom de l'entreprise est vide, on ignore la ligne
    if [ -z "$nom" ]; then
        echo "  [ligne $LINE_NUM] ignorée : 'nom' vide"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Valeurs par défaut si les champs ne sont pas renseignés dans le CSV
    statut="${statut:-1}"
    client="${client:-0}"
    fournisseur="${fournisseur:-0}"
    
    # Construction de la requête SQL d'insertion dans la table des tiers de Dolibarr (llx_societe)
    SQL="INSERT INTO llx_societe (nom, entity, status, client, fournisseur, address, zip, town, phone, email, datec) VALUES ('$(esc "$nom")', 1, ${statut}, ${client}, ${fournisseur}, '$(esc "$address")', '$(esc "$zip")', '$(esc "$town")', '$(esc "$phone")', '$(esc "$email")', NOW());"
    
    # Exécution de la requête SQL dans le conteneur MariaDB/MySQL
    docker exec "$DB_CONTAINER" mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" -e "$SQL"
    
    IMPORTED=$((IMPORTED + 1))
    echo "  [ligne $LINE_NUM] importée : $nom"
done < <(tail -n +2 "$CSV_FILE") # On ignore la première ligne du CSV (l'en-tête)

echo "=== Import terminé : $IMPORTED insérées, $SKIPPED ignorées ==="
