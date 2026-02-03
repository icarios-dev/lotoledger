1. récupération des données

```sh
make -C ops data
```

2. ingestion en base

```sh
make -C db populate
```

3. lancement de l'API

```sh
cd apps/api
gleam run
```
