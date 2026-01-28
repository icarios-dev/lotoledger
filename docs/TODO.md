# TODO

## MVP

* connexion via _DATABASE_URL=_
* requêtes paramétrées
* _src/db/queries/*.gleam_

### Endpoints

[] _GET /health_
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
