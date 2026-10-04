# Test du PRA (Plan de Reprise d'Activité)

## Objectif

Vérifier qu'après une perte totale du serveur (conteneurs et volumes supprimés), on peut repartir de zéro avec `install.sh` et retrouver toutes les données grâce à une sauvegarde.

## Environnement de test

- Machine virtuelle Ubuntu, accès en SSH
- Docker et Docker Compose
- Deux conteneurs : Dolibarr (`dolibarr/dolibarr:latest`) et MariaDB (`mariadb:10.11`)
- Données : 4 tiers (clients/fournisseurs) importés avec `scripts/import_csv.sh`
- Date du test : 03/10/2026

## État avant la sauvegarde

Requête exécutée :

```bash
source .env
docker compose exec db mariadb -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
  -e "SELECT rowid, nom, client, fournisseur FROM llx_societe;"
```

Résultat : 4 tiers présents.

```
 +-------+---------------------------+--------+-------------+
| rowid | nom                       | client | fournisseur |
+-------+---------------------------+--------+-------------+
|     1 | Vasseur Automobile        |      1 |           0 |
|     2 | Petit Imprimerie          |      1 |           0 |
|     3 | Lemaitre Electricite SARL |      0 |           1 |
|     4 | Caron Fournitures Bureau  |      0 |           1 |
+-------+---------------------------+--------+-------------+


```

## Procédure testée

1. **Sauvegarde**
```bash
   ./scripts/backup.sh
   ls -lh backups/
```
   Archive produite : `dolibarr_backup_20261003_232420.tar.gz` (environ 134 Ko).

2. **Vérification du contenu de l'archive**
```bash
   tar -tzf backups/dolibarr_backup_20261003_232420.tar.gz
```
   Contenu :
   - `dolibarr_db.sql` : dump complet de la base de données
   - `dolibarr_documents.tar.gz` : archive du volume des documents Dolibarr

3. **Simulation de l'incident** (suppression des conteneurs et des volumes)
```bash
   docker compose down -v
```

4. **Réinstallation à partir de zéro**
```bash
   ./install.sh
```
   Dolibarr redémarre avec une base vide.

5. **Restauration**
```bash
   ./scripts/restore.sh backups/dolibarr_backup_20261003_232420.tar.gz
```

## État après la restauration

Même requête SQL qu'avant.

```
+-------+---------------------------+--------+-------------+
| rowid | nom                       | client | fournisseur |
+-------+---------------------------+--------+-------------+
|     1 | Vasseur Automobile        |      1 |           0 |
|     2 | Petit Imprimerie          |      1 |           0 |
|     3 | Lemaitre Electricite SARL |      0 |           1 |
|     4 | Caron Fournitures Bureau  |      0 |           1 |
+-------+---------------------------+--------+-------------+

```

Dans l'interface Dolibarr (Tiers → Liste), les 4 tiers sont de nouveau présents et la connexion fonctionne avec les identifiants habituels.

## Résultat

| Critère | Attendu | Obtenu |
|---|---|---|
| Archive de sauvegarde créée | oui | oui |
| Archive contenant dump SQL et documents | oui | oui |
| Réinstallation avec `install.sh` | sans erreur | oui |
| Nombre de tiers après restauration | 4 | 4 |
| Valeurs Client/Fournisseur identiques | oui | oui |
| Connexion à Dolibarr | possible | possible |

**Conclusion** : le PRA est validé. À partir d'une archive de sauvegarde, `install.sh` puis `restore.sh` permettent de reconstruire un Dolibarr fonctionnel avec toutes les données.

## Remarques

- Le `.env` doit rester identique entre la sauvegarde et la restauration (mots de passe, `DOLI_URL_ROOT`). Il n'est pas inclus dans l'archive et ne doit jamais être versionné.
- Le `.env` et le dossier `backups/` sont exclus de Git, car les archives contiennent toute la base.
- La sauvegarde a été lancée avec `sudo`, ce qui rend l'archive propriétaire `root`. Il vaut mieux lancer le script sans `sudo` (utilisateur dans le groupe `docker`).
- Pour une vraie production, il faudrait copier les archives hors de la machine (autre serveur, stockage distant) et automatiser la sauvegarde avec `cron`.


