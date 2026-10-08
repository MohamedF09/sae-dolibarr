#!/usr/bin/env bash
# Arrête immédiatement le script en cas d'erreur, de variable non définie ou d'échec dans un pipe
set -euo pipefail

# Récupération du répertoire du script et positionnement à la racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"
# Chargement des variables d'environnement (identifiants de base de données, nom de la BDD, etc.)
source .env

# Définition du répertoire de sauvegarde (par défaut ./backups)
BACKUP_DIR="${BACKUP_DIR:-./backups}"
DB_CONTAINER="dolibarr_db"
APP_CONTAINER="dolibarr_app"
# Génération d'un horodatage unique basé sur la date et l'heure actuelles (ex: 20261008_140100)
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
# Création d'un répertoire temporaire pour stocker les fichiers de la sauvegarde en cours
WORKDIR="$(mktemp -d)"
# S'assure que le dossier de destination des sauvegardes existe
mkdir -p "$BACKUP_DIR"

echo "=== Dump SQL ==="
# Exécution de mysqldump à l'intérieur du conteneur de base de données pour exporter toutes les tables de Dolibarr
docker exec "$DB_CONTAINER" mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" --single-transaction "${DB_NAME}" > "${WORKDIR}/dolibarr_db.sql"

echo "=== Archive des documents ==="
# Utilisation d'un conteneur Alpine temporaire rattaché aux volumes du conteneur applicatif 
# pour archiver le dossier des documents (factures, PDFs, logos, etc.) de Dolibarr
docker run --rm --volumes-from "$APP_CONTAINER" -v "${WORKDIR}:/backup" alpine tar czf /backup/dolibarr_documents.tar.gz -C /var/www documents

# Nom final de l'archive compressée contenant le dump SQL et l'archive des documents
FINAL_ARCHIVE="${BACKUP_DIR}/dolibarr_backup_${TIMESTAMP}.tar.gz"
# Regroupement de tous les éléments de la sauvegarde dans l'archive finale compressée (.tar.gz)
tar czf "$FINAL_ARCHIVE" -C "$WORKDIR" dolibarr_db.sql dolibarr_documents.tar.gz
# Suppression du répertoire temporaire de travail sur l'hôte
rm -rf "$WORKDIR"

echo "=== Sauvegarde terminée : $FINAL_ARCHIVE ==="
# Affichage de la taille du fichier d'archive généré
du -h "$FINAL_ARCHIVE"
