#!/usr/bin/env bash
# Arrête le script en cas d'erreur, de variable non définie ou d'échec dans un pipe
set -euo pipefail

# Récupération du répertoire du script et positionnement à la racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# Récupération du chemin de l'archive de sauvegarde passée en argument
ARCHIVE="${1:-}"
if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
    echo "Usage : $0 <archive.tar.gz>" >&2
    exit 1
fi

# Chargement des variables d'environnement (identifiants de base de données, etc.)
source .env
DB_CONTAINER="dolibarr_db"
APP_CONTAINER="dolibarr_app"
# Création d'un répertoire temporaire pour extraire l'archive
WORKDIR="$(mktemp -d)"

# Vérification que le conteneur de la base de données est bien en cours d'exécution
if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}\$"; then
    echo "Erreur : lance d'abord ./install.sh" >&2
    exit 1
fi

echo "=== Extraction ==="
# Extraction de l'archive tar.gz dans le dossier temporaire
tar xzf "$ARCHIVE" -C "$WORKDIR"

echo "=== Restauration base de données ==="
# Injection du fichier SQL sauvegardé dans le conteneur MariaDB/MySQL
docker exec -i "$DB_CONTAINER" mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${WORKDIR}/dolibarr_db.sql"

echo "=== Restauration documents ==="
# Copie de l'archive des documents vers le conteneur applicatif Dolibarr
docker cp "${WORKDIR}/dolibarr_documents.tar.gz" "${APP_CONTAINER}:/tmp/dolibarr_documents.tar.gz"
# Nettoyage des anciens documents, extraction de la sauvegarde et suppression de l'archive temporaire dans le conteneur
docker exec "$APP_CONTAINER" sh -c "rm -rf /var/www/documents/* && tar xzf /tmp/dolibarr_documents.tar.gz -C /var/www && rm /tmp/dolibarr_documents.tar.gz"

# Suppression du répertoire temporaire sur l'hôte
rm -rf "$WORKDIR"
echo "=== Restauration terminée ==="
