# Algèbre effective en OCaml

Projet de **L2 Informatique** (Université de Rouen Normandie) — implémentation en OCaml d'une bibliothèque d'**algèbre symbolique** : structures algébriques (entiers et rationnels de Gauss, polynômes rationnels) et algorithmes associés (interpolation de Newton, développement de Taylor de fractions rationnelles).

Toute l'arithmétique repose sur la bibliothèque [`zarith`](https://github.com/ocaml/Zarith) qui fournit le calcul **exact** sur grands entiers et nombres rationnels — pas d'arithmétique flottante, donc aucune erreur d'arrondi.

## 📦 Architecture

Le projet est organisé en **trois bibliothèques** + **un binaire de test**, gérés par [`dune`](https://dune.build/).

```
algebre_effective/
├── e_gauss/       # ℤ[i] — entiers de Gauss
├── r_gauss/       # ℚ[i] — rationnels de Gauss
├── q_poly/        # ℚ[X] — polynômes à coefficients rationnels
└── test/          # binaire de démonstration
```

| Module    | Description                                                          | LOC |
|-----------|----------------------------------------------------------------------|-----|
| `e_gauss` | Entiers de Gauss ℤ[i] : addition, multiplication, conjugué, norme    | 153 |
| `r_gauss` | Rationnels de Gauss ℚ[i] : extension de `e_gauss` aux complexes ℚ    | 182 |
| `q_poly`  | Polynômes ℚ[X] en représentation creuse + algorithmes du sujet       | 566 |
| `test`    | Démonstrations et tests des fonctions implémentées                   | 251 |

## ✨ Fonctionnalités principales

### `e_gauss` — Entiers de Gauss ℤ[i]
- Types et constantes : `zero`, `one`, `i`, `minus_one`, `minus_i`
- Parties réelle / imaginaire, conjugué, norme
- Addition, soustraction, multiplication
- Conversions et affichage

### `r_gauss` — Rationnels de Gauss ℚ[i]
- Mêmes opérations que `e_gauss` étendues aux rationnels
- Division (corps des fractions)
- Inverse multiplicatif

### `q_poly` — Polynômes ℚ[X]
Représentation **creuse** : un polynôme = liste `(degré, coefficient)` triée, sans coefficients nuls.

**Opérations classiques :**
- Construction, normalisation (`purge`), accès par degré, degré, coefficient dominant
- Arithmétique : `add`, `sub`, `mult_naive`, `mult`, `mult_coeff`, `mult_monome`
- Division euclidienne : `quotient`, `reste`, `modulo`
- Évaluation, dérivée, élévation à une puissance
- Inversion modulaire (`inverse_mod`)

**Algorithmes avancés (projet) :**
- Opérateur **différence finie** `Δ` et ses itérés `Δⁿ`
- **Interpolation de Newton** sur la grille des entiers (`interpol_newton`)
- Méthode des différences finies pour la prédiction de suites
- **Développement de Taylor de fractions rationnelles** P/Q à l'ordre `n`, par deux méthodes :
  - Méthode directe (sommation des dérivées en 0)
  - Méthode de Newton (inversion modulaire du dénominateur)

## 🚀 Compilation et exécution

### Prérequis

- OCaml ≥ 4.14
- [`dune`](https://dune.build/) ≥ 3.17
- [`zarith`](https://github.com/ocaml/Zarith)

Installation des dépendances via `opam` :

```bash
opam install dune zarith
```

### Build

À la racine du projet :

```bash
dune build
```

### Exécution des tests / démos

```bash
dune exec test/main.exe
```

## 📐 Choix techniques

- **Représentation creuse des polynômes** : `(int * Q.t) list` triée par degré croissant. Évite de stocker les coefficients nuls et accélère les opérations sur les polynômes peu denses.
- **Arithmétique exacte** : grâce à `zarith`, tous les calculs sont exacts, sans aucune perte de précision. Indispensable en algèbre symbolique.
- **Séparation interface / implémentation** : chaque bibliothèque expose une interface (`.mli`) documentée. Ça permet de vérifier les invariants à la compilation et facilite la maintenance.
- **Build hermétique avec `dune`** : reproductible, sans aucune configuration manuelle.

## 📚 Contexte académique

Projet réalisé dans le cadre de l'UE d'**Algèbre effective** en L2 Informatique à l'Université de Rouen Normandie. Le sujet original est inclus dans [`q_poly/sujet_projet.pdf`](q_poly/sujet_projet.pdf).

## 📄 Licence

Code académique fourni à titre éducatif.
