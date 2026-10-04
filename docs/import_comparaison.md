# Comparaison des méthodes d'import CSV

## Méthode A : assistant d'import Dolibarr (Outils → Importer)
- Principe, fichier utilisé, étapes
- Avantages : simple, validation par Dolibarr
- Limites : manuelle, non automatisable
- Bug constaté : les champs Client/Fournisseur ne sont pas
  correctement enregistrés en base (colonnes client, fournisseur
  de llx_societe)

## Méthode B : import SQL direct (scripts/import_csv.sh)
- Principe : lecture du CSV, INSERT dans llx_societe
- Avantages : automatisable, Client/Fournisseur corrects
- Limites : contourne la logique métier de Dolibarr

## Conclusion et choix retenu
