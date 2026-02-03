* __bootstrap/__
  tout ce qui prépare la sécurité/structure “système” (roles, schemas, grants)
* __schema/__
  ce qui décrit la DB (types, tables)
* __routines/__
  fonctions/procs/views/triggers SQL
* __seeds/__
  données d’exemple / dev (pas le dataset source)
* __assets/datasets/__
  tes CSV historiques (source brute), bien séparés des seeds
* __admin/__
  scripts “outils” (nuke, test PLS, etc.)

## Récupération des données

Les fichiers CSV ne sont pas versionnés dans ce dépôt.

Pour les récupérer localement :

`make data` (ou `./scripts/fetch_data.sh`), puis `make populate`.
