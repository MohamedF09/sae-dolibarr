# Suivi de projet - sae-dolibarr

## Séance 1

**Présents :** [ton nom]

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

**Présents :** [ton nom]

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

**Présents :** [ton nom]

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
