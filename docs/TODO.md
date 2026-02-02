# TODO

## MVP

* connexion via _DATABASE_URL=_
* requêtes paramétrées
* _src/db/queries/*.gleam_

### Endpoints

[*] _GET /health_
  test de déploiement, monitoring simple
  ```sql
  select 1 ;
  ```

[*] _GET /api/rulesets_
  liste des `rule_set` présents (ou supportés)
  ```sql
  select distinct rule_set from app.draws ;
  ```

[] _GET /api/draws?rule_set=…&from=…&to=…&limit=…_ paginé
  data brute filtrée

## v1

### table de règles

(ruleset DB → Gleam) : très bon instinct. Garder les règles en base rend
l’évolution plus simple et évite de “recompiler pour changer un
paramètre”.

Architecture propre :

  - table `app.rule_sets` (ou similaire) : `code`, `min_main`, `max_main`,
    `size_max_main`, éventuellement règles bonus
  - fonction `app.get_rule_set(code)` : renvoie les paramètres
  - côté Gleam : tu charges le ruleset au démarrage (cache en mémoire) ou
    à la demande (selon ton trafic), puis tu passes ces valeurs à
    `normalize_pick`.

### normalization en API

Ok

### normalization en DB

TODO

### branchement normalize_pick

on branche `normalize_pick` dans ton handler Wisp, puis on passe
`normalized_pick` à `api.pick_stats_v1`.

Ensuite seulement, on discute pagination/limit sur `draws` (sinon un
pick à 1 numéro peut te renvoyer un roman).
