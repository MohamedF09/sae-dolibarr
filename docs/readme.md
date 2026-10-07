# sae-dolibarr

SAE51 - projet 3 : Installation d'un ERP/CRM (Dolibarr) — IUT Rouen, BUT3 RT.

Mise en place d'un Dolibarr fonctionnel, dockerisé, avec import des données
existantes (Tiers) et procédure de sauvegarde / reprise après incident (PRA).

## Équipe

- Chef de projet : [nom]
- Membre : Evan-972

## Structure du dépôt

```
sae-dolibarr
├── docs/
│   ├── import_comparaison.md   # comparaison des deux méthodes d'import
│   └── test_pra.md             # compte-rendu du test de sauvegarde/restauration
├── scripts/
│   ├── import_csv.sh           # import direct des Tiers en base (via le conteneur SGBD)
│   ├── backup.sh                # sauvegarde (dump SQL + documents)
│   └── restore.sh               # restauration (PRA)
├── docker-compose.yml           # Dolibarr + MariaDB, deux conteneurs séparés
├── .env.example                 # modèle de configuration (à copier en .env)
├── .gitignore
├── install.sh                   # installation complète via Docker
├── sources.md
├── suivi_projet.md
├── tiers_import_test.csv        # données de test pour l'import via l'UI web
├── tiers_import_direct.csv      # données de test pour l'import SQL direct
└── readme.md
```

## Démarrage rapide

```bash
git clone <url_du_depot>
cd sae-dolibarr
cp .env.example .env        # puis éditer les mots de passe
./install.sh                # installe et démarre Dolibarr + MariaDB (Docker)
./scripts/import_csv.sh tiers_import_direct.csv
./scripts/backup.sh
```

Dolibarr est accessible sur `http://<IP>:8080/` une fois l'installation terminée.

### Reprise après incident (PRA)

```bash
./install.sh
./scripts/restore.sh backups/dolibarr_backup_XXXXXXXX_XXXXXX.tar.gz
```

Cycle testé et validé : sauvegarde → destruction des conteneurs
(`docker compose down -v`) → réinstallation → restauration.
Détails dans [`docs/test_pra.md`](docs/test_pra.md).

## Périmètre fonctionnel

POC limité à la gestion des Tiers (clients/fournisseurs) dans Dolibarr.

## Deux méthodes d'import comparées

1. **Assistant web Dolibarr** (menu Outils) : simple, mais le mapping des champs
   Client/Fournisseur ne s'enregistre pas correctement en base (bug constaté).
2. **Import SQL direct** (`scripts/import_csv.sh`) : plus fiable, scriptable,
   utilisé pour l'automatisation finale.

Détails dans [`docs/import_comparaison.md`](docs/import_comparaison.md).

## Documentation

Voir [`suivi_projet.md`](suivi_projet.md) pour le journal de bord du projet
et [`sources.md`](sources.md) pour les ressources utilisées.
