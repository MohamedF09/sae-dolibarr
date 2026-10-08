#!/usr/bin/env bash
# Arrête immédiatement le script si une commande échoue, si une variable n'est pas définie, ou dans un pipe
set -euo pipefail

# Récupération du dossier où se trouve ce script et déplacement dedans
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/4] Vérification des prérequis ==="
# Vérifie si Docker est installé sur la machine
if ! command -v docker &>/dev/null; then
    echo "Erreur : docker n'est pas installé." >&2
    exit 1
fi
# Vérifie si Docker Compose (v2) est bien disponible
if ! docker compose version &>/dev/null; then
    echo "Erreur : le plugin 'docker compose' n'est pas disponible." >&2
    exit 1
fi

echo "=== [2/4] Vérification du fichier .env ==="
# Vérifie que le fichier de configuration des variables d'environnement existe
if [ ! -f .env ]; then
    echo "Erreur : fichier .env manquant. Crée-le à partir de .env.example." >&2
    exit 1
fi

echo "=== [3/4] Démarrage des conteneurs (SGBD + Dolibarr) ==="
# Lance les conteneurs définis dans le docker-compose.yml en arrière-plan (-d)
docker compose up -d

echo "=== [4/4] Attente que Dolibarr soit fonctionnel ==="
# Charge les variables du fichier .env pour récupérer le port HTTP configuré
source .env
HTTP_PORT="${HTTP_PORT:-8080}"
MAX_WAIT=300
WAITED=0

# Boucle d'attente tant que l'application ne renvoie pas un code HTTP 200 ou 302
until curl -s -o /dev/null -w "%{http_code}" "http://localhost:${HTTP_PORT}/" | grep -qE "^(200|302)$"; do
    if [ "$WAITED" -ge "$MAX_WAIT" ]; then
        echo "Erreur : Dolibarr ne répond toujours pas après ${MAX_WAIT}s." >&2
        exit 1
    fi
    sleep 5
    WAITED=$((WAITED + 5))
    echo "  ... en attente (${WAITED}s)"
done

echo "=== Installation terminée ==="
echo "Dolibarr est accessible sur : http://localhost:${HTTP_PORT}/"
echo "Compte admin : ${DOLI_ADMIN_LOGIN:-superadmin}"
