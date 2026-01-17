# architecture base de données

## objectifs
- une base dédiée par application (ici : `app_loto`)
- séparation nette entre données applicatives et opérations d'import/ETL
- permissions minimales, reproductibles, et faciles à auditer
- accès applicatif via une api SQL (fonctions), pas via accès direct aux tables

## périmètre
- Postgres (cluster local en dev)
- convention de nommage : tout ce qui est spécifique au projet est
  préfixé du nom de la base (`app_loto_`) (rôles), et rangé dans des schémas dédiés (objets).

## schémas
- `app` : modèle applicatif “stable”
  - tables de production, vues, indexes
  - fonctions exposées à l'application (api SQL)
- `work` : zone de travail / ETL
  - tables raw de staging (import CSV)
  - fonctions d’ingestion, normalisation, contrôles
  - scripts d’import (pilotés via `psql \copy`)

**principe** : l'application ne dépend jamais de `work`.

## rôles
- `app_loto_owner` (nologin)
  - propriétaire de tous les objets (tables, fonctions, schémas)
  - seul rôle qui fait du DDL (create/alter/drop) via scripts
- `app_loto_admin` (login)
  - exécute les corvées : import CSV, rebuild, nettoyage, tâches ETL
  - accès en lecture/écriture sur `work`, et uniquement ce qui est nécessaire sur `app`
- `app_loto_user` (login)
  - rôle utilisé par l'application
  - n’a pas d’accès direct aux tables (pas de select/insert/update/delete sur `app.*`)
  - accès uniquement via `execute` sur des fonctions `api.*` (api SQL)
  - Le rôle applicatif (app_loto_user) ne dispose d’aucun accès direct
    aux données. Toute interaction passe exclusivement par les fonctions
    exposées dans le schéma api.
- `app_loto_pls` (nologin)
  - rôle lecture/outil (Postgres Language Server)
  - accordé à l'utilisateur Unix local via membership (auth `peer`)
  - permet autocomplete/hover sans mots de passe

## permissions
- `app_loto_user` :
  - `usage` sur le schéma `app`
  - `execute` sur les fonctions exposées (`app.*`)
  - pas d’accès direct aux tables (sauf exception documentée)
- `app_loto_admin` :
  - droits nécessaires sur `work` (staging + ingest)
  - peut exécuter les fonctions d’ingestion qui écrivent dans `app`
- `app_loto_pls` :
  - `usage` sur `app` (et éventuellement `work`)
  - `select` sur tables/vues utiles à la navigation
  - `execute` sur fonctions nécessaires aux définitions
- `default privileges` :
  - appliqués pour le rôle créateur (`app_loto_owner`) afin que les
    nouveaux objets héritent automatiquement des bons droits
    (pls/admin/user).

## identité vs contenu (exemple loto)
- `draw_key` : représente le contenu (combinaison), utile pour stats/index, mais pas unique
- unicité «événement» : clé basée sur l'identifiant de tirage (ex: `rule_set + draw_ref + draw_sub`)

## scripts
- `create_roles.sql` : création rôles + memberships (sans secrets versionnés)
- `build.sql` : DDL (schémas/tables/fonctions/index + grants + default privileges)
- `populate.sql` : rebuild complet via staging (`\copy`) + ingestion
- `update*.sql` : incrémental (staging + `insert ... on conflict` sur identité de tirage)
- `nuke.sql` : destruction totale (db + rôles du projet)

## règles pratiques
- `\copy` lit côté client : les CSV sont lus par l'utilisateur qui exécute `psql`
- pas d’objets dans `public` (éviter les surprises)
- un seul rôle «créateur» d’objets par schéma (`app_loto_owner`) pour garder les droits prédictibles
- les fonctions api.* doivent inclure `security definer` et `search_patch`
