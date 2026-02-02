
## Normalisation d’une sélection (pick) — contrat v1

Cette API accepte une sélection de numéros (“pick”) fournie par
l’utilisateur, et la transforme en une forme canonique avant tout
traitement.

### Entrée attendue

* Une liste d’entiers (`List(Int)` côté backend).
* La liste représente un **ensemble** : l’ordre n’a pas de signification.
* La liste ne représente **pas** un tirage complet : une sélection de
  **1 à N** numéros est autorisée (N dépend du jeu / ruleset).

### Règles de validation (fail fast)

Soit :

* `min` = valeur minimale autorisée (incluse)
* `max` = valeur maximale autorisée (incluse)
* `size_max` = nombre maximal de valeurs **reçues** dans la requête

La normalisation applique les règles suivantes, dans cet ordre :

1. **Taille**

* Si la liste est vide → erreur `EmptyPick`
* Si `length(raw) > size_max` → erreur `TooManyNumbers(max=size_max, got=length(raw))`

2. **Bornes**

* Si au moins une valeur `n` vérifie `n < min` ou `n > max` → erreur
  `OutOfRange(min=min, max=max, got=n)`
  (`got` est la première valeur hors bornes rencontrée)

### Tolérance sur les doublons

* Les doublons sont **acceptés** en entrée (ex : `[4, 4, 12]`).
* Ils sont **supprimés** lors de la canonicalisation (voir ci-dessous).
* Attention : la contrainte `size_max` s’applique **avant** suppression des doublons.
  Exemple : avec `size_max=5`, `[1,1,1,1,1,1]` est rejeté (erreur de taille).

### Canonicalisation (forme canonique)

Si la validation passe, la sélection est transformée en :

* tri **croissant**
* suppression des **doublons**
* résultat stable (même entrée ⇒ même sortie canonique)

Exemple :

* Entrée : `[33, 12, 21, 4, 33]`
* Sortie canonique : `[4, 12, 21, 33]`

### Erreurs renvoyées

* `EmptyPick` : aucune valeur fournie
* `TooManyNumbers(max, got)` : trop de valeurs dans la requête
* `OutOfRange(min, max, got)` : valeur hors bornes

