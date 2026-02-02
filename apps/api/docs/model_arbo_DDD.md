%% vim: nowrap

```sh
apps/api/
├── gleam.toml
├── README.md
├── src/
│   ├── main.gleam                 # démarre l'app (config + supervisor + http server)
│   ├── config/
│   │   ├── config.gleam           # lecture env, validation, types Config
│   │   └── secrets.gleam          # optionnel: gestion secrets / redaction logs
│   ├── shared/
│   │   ├── domain/
│   │   │   ├── errors.gleam       # DomainError, invariants, Result helpers
│   │   │   └── types.gleam        # types partagés stables (RuleSetId, DrawId, etc.)
│   │   ├── application/
│   │   │   └── clock.gleam        # ports transverses (time, uuid, etc.)
│   │   ├── infrastructure/
│   │   │   ├── db.gleam           # pool/connexion pog + helpers safe (transactions)
│   │   │   └── logging.gleam      # logging structuré, corrélation request-id
│   │   └── presentation/
│   │       ├── http.gleam         # helpers wisp: responses JSON, error mapping
│   │       └── json.gleam         # encoders/decoders communs
│   ├── system/
│   │   ├── presentation/
│   │   │   ├── routes.gleam       # /health
│   │   │   └── handler_health.gleam
│   │   └── application/
│   │       └── health_check.gleam # use-case trivial (optionnel)
│   ├── rulesets/
│   │   ├── domain/
│   │   │   ├── ruleset.gleam      # entity/value object (RuleSet)
│   │   │   └── repository.gleam   # port: behaviour/interface
│   │   ├── application/
│   │   │   └── list_rulesets.gleam # use-case
│   │   ├── infrastructure/
│   │   │   └── repo_postgres.gleam # adapter: impl repository via Postgres
│   │   └── presentation/
│   │       ├── routes.gleam
│   │       ├── handler_list.gleam
│   │       └── dto.gleam          # JSON shape API (si différent du domain)
│   ├── draws/
│   │   ├── domain/
│   │   │   ├── draw.gleam
│   │   │   ├── query.gleam        # DrawQuery (rule_set/from/to/limit)
│   │   │   └── repository.gleam
│   │   ├── application/
│   │   │   └── list_draws.gleam
│   │   ├── infrastructure/
│   │   │   └── repo_postgres.gleam
│   │   └── presentation/
│   │       ├── routes.gleam
│   │       ├── handler_list.gleam
│   │       └── dto.gleam
│   ├── router/
│   │   └── router.gleam           # assemble toutes les routes (composition root)
│   └── composition/
│       ├── wiring.gleam           # construit les deps (repos postgres, services, etc.)
│       └── modules.gleam          # optionnel: registre des bounded contexts
├── test/
│   ├── draws_application_test.gleam
│   ├── rulesets_application_test.gleam
│   └── shared_domain_test.gleam
└── priv/
    └── openapi.yaml               # ou ../contract/ selon ton choix
```


* `domain/`
  - types métier (Entities / Value Objects) + invariants
  - zéro json, zéro pog, zéro wisp

* `application/`
  - orchestration métier (use cases) : “quoi faire”, dans quel ordre,
    avec quelles règles
  - dépend d’interfaces (ports) définies dans domain ou application,
    jamais de l’infra

* `infrastructure/`
  - accès DB (pog), implémentations des interfaces, config, adapters

* `presentation/`
  - HTTP (wisp), parsing request, mapping erreurs → HTTP
  - sérialisation JSON et types “contract”

* Si un type sert **à parler au client HTTP** → `presentation/contract`
* Si un type sert **à penser le métier** → `domain/`
* Si un type sert **à parler à Postgres** → `infrastructure/`
