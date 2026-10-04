# Suivi de projet - sae-dolibarr

## Séance 1

Mohamed Ftaimiya & Evan Ursulet

**Ce qui a été fait :**
- Création de la VM Debian sous VirtualBox (2 vCPU, 2 Go RAM, 20 Go disque)
- Installation des prérequis : Apache2, PHP (+ extensions mysqli, curl, gd, intl, mbstring, xml, zip, imap), MariaDB
- Sécurisation de MariaDB (mariadb-secure-installation)
- Téléchargement de Dolibarr 20.0.0 (source) et déplacement dans /var/www/dolibarr
- Configuration du VirtualHost Apache (dolibarr.conf), activation du module rewrite
- Création de la base de données `dolibarr` et de l'utilisateur SQL dédié

**Difficultés rencontrées :**
- Échec initial du téléchargement Dolibarr via SourceForge (lien de redirection), contourné en passant par GitHub

**Reste à faire :**
- Lancer l'assistant d'installation web (/install/)

---

## Séance 2

Mohamed Ftaimiya & Evan Ursulet

**Ce qui a été fait :**
- Lancement de l'assistant d'installation Dolibarr (http://<ip_vm>/install/)
- Connexion réussie à la base de données via le formulaire (host, nom de base, login/mot de passe SQL)
- Arrivée à l'étape de création du compte administrateur (step4.php)

**Difficultés rencontrées :**
- Premier mot de passe admin saisi trop court (4 caractères), corrigé
- Confusion initiale entre le login SQL (`dolibarr`) et le login admin Dolibarr (`superadmin`)

**Reste à faire :**
- Finaliser la création du compte superadmin
- Se connecter à l'interface Dolibarr

---

## Séance 3

Mohamed Ftaimiya & Evan Ursulet

**Ce qui a été fait :**
- Finalisation de l'installation (création du compte superadmin)
- Première connexion à Dolibarr et configuration initiale de la société
- Activation du module "Tiers" (Third parties)
- Création d'un compte utilisateur standard ("user1"), distinct du superadmin
- Création manuelle d'un tiers de test pour comprendre les champs utilisés par Dolibarr (nom, adresse, client/fournisseur, etc.)

**Difficultés rencontrées :**
- Incertitude sur le champ "responsable hiérarchique" lors de la création d'utilisateur (laissé vide, non bloquant pour le POC)

**Reste à faire :**
- Étape 1 (découverte/install manuelle) terminée ✅
- Passer à l'étape 2 : import des données CSV via le menu "Outils" de Dolibarr, puis comparer avec un import direct en base (table llx_societe)
- Commencer à documenter la structure de llx_societe dans docs/

## Séance 4

Mohamed Ftaimiya & Evan Ursulet

**Ce qui a été fait :**
- Test de la méthode 1 (import via l'assistant web de Dolibarr, menu Outils) : 8 tiers importés avec succès, mais le mapping des champs Client/Fournisseur ne s'est pas appliqué correctement (valeurs restées à 0 en base malgré le mapping)
- Inspection de la structure réelle de la table llx_societe via SQL (DESCRIBE)
- Écriture et test d'un script d'import direct en base (import_csv.sh), contournant l'interface Dolibarr
- Test réussi : 4 tiers importés directement via le script, avec cette fois les valeurs Client/Fournisseur correctement enregistrées

**Difficultés rencontrées :**
- Mot de passe MySQL de l'utilisateur dolibarr oublié, récupéré via reset avec le compte root (authentification socket sur Debian)
- Mapping Client/Fournisseur non fonctionnel via l'assistant d'import web, contournable via import SQL direct

**Reste à faire :**
- Comparer et documenter les deux méthodes dans docs/ (avantages/inconvénients)
- Passer à l'étape 3 : dockerisation (Dolibarr + SGBD en conteneurs séparés) et scripts maîtres install.sh / import_csv.sh finaux

## Séance 5 – 04/10/2026
**Réalisé**
- Dockerisation : Dolibarr + MariaDB (2 conteneurs), scripts install/import/backup/restore
- Test complet du PRA (backup → down -v → install → restore) : 4 tiers retrouvés
- Import CSV validé

**Incident**
- `.env` committé par erreur, retiré du dépôt, mots de passe changés

**Reste à faire**
- Finaliser la doc
