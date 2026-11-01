# Algèbre effective en OCaml, vers un RSA jouet

[![CI](https://github.com/RIZIWYX/RSA/actions/workflows/ci.yml/badge.svg)](https://github.com/RIZIWYX/RSA/actions/workflows/ci.yml)
![OCaml](https://img.shields.io/badge/OCaml-%E2%89%A5%204.14-orange)
![zarith](https://img.shields.io/badge/calcul-exact%20(zarith)-blue)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-green)](LICENSE)

Bibliothèque OCaml d'**algèbre symbolique** réalisée en L2 Informatique (Université de Rouen Normandie) : entiers et rationnels de Gauss, polynômes à coefficients rationnels, interpolation de Newton et développement de Taylor de fractions rationnelles.

Toute l'arithmétique repose sur [`zarith`](https://github.com/ocaml/Zarith), qui calcule **exactement** sur des entiers et des rationnels de taille arbitraire : pas de flottants, donc aucune erreur d'arrondi.

Le projet est en train d'être étendu en **RSA jouet** : génération de clés, chiffrement, puis attaques sur de petites clés pour montrer pourquoi la vraie cryptographie utilise de grandes clés et du padding.

## État du projet

| Partie | État | Branche |
|---|---|---|
| Algèbre effective (`e_gauss`, `r_gauss`, `q_poly`) | Terminé | `main` |
| Briques arithmétiques : Euclide étendu, inverse et exponentiation modulaires | Fait, avec tests | [`rsa-jouet`](https://github.com/RIZIWYX/RSA/tree/rsa-jouet) |
| Tests de primalité (Miller-Rabin) et génération de premiers | À venir | `rsa-jouet` |
| RSA : clés, chiffrement, déchiffrement | À venir | `rsa-jouet` |
| Attaques : divisions successives, Fermat, Pollard rho, petit exposant | À venir | `rsa-jouet` |

La feuille de route complète est dans [`ROADMAP.md`](https://github.com/RIZIWYX/RSA/blob/rsa-jouet/ROADMAP.md), sur la branche `rsa-jouet`. Le RSA rejoindra `main` une fois terminé.

> RSA jouet = projet pédagogique. Les clés sont volontairement petites et il n'y a pas de padding : ce code ne doit pas servir à protéger de vraies données.

## Architecture

Le projet est organisé en **trois bibliothèques** + **un binaire de test**, gérés par [`dune`](https://dune.build/).

```
RSA/
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

## Fonctionnalités principales

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

## Compilation et exécution

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

Le programme passe en revue les fonctions de `q_poly` (puissances, différences finies, interpolation de Newton, développements de Taylor) et affiche pour chacune le résultat attendu à côté du résultat obtenu. La CI compile le projet et lance ce programme à chaque push.

## Choix techniques

- **Représentation creuse des polynômes** : `(int * Q.t) list` triée par degré croissant. Évite de stocker les coefficients nuls et accélère les opérations sur les polynômes peu denses.
- **Arithmétique exacte** : grâce à `zarith`, tous les calculs sont exacts, sans aucune perte de précision. Indispensable en algèbre symbolique.
- **Séparation interface / implémentation** : chaque bibliothèque expose une interface (`.mli`) documentée. Ça permet de vérifier les invariants à la compilation et facilite la maintenance.
- **Build hermétique avec `dune`** : reproductible, sans aucune configuration manuelle.

## Contexte académique

Projet réalisé dans le cadre de l'UE d'**Algèbre effective** en L2 Informatique à l'Université de Rouen Normandie. Le sujet original est inclus dans [`q_poly/sujet_projet.pdf`](q_poly/sujet_projet.pdf).

## Auteurs

Rayane Graïne et Accyl Benadjaoud, L2 Informatique, Université de Rouen Normandie.

## Licence

Distribué sous licence **MIT**. Voir le fichier [`LICENSE`](LICENSE).
