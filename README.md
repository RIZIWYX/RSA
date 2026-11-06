# Algèbre effective et RSA pédagogique en OCaml

![CI](https://github.com/RIZIWYX/RSA/actions/workflows/ci.yml/badge.svg)

Bibliothèque OCaml d'**arithmétique exacte** (entiers et rationnels de Gauss, polynômes rationnels), étendue en **projet de cryptographie pédagogique** : un RSA jouet écrit à partir de zéro, destiné à être attaqué sur de petites clés.

Toute l'arithmétique repose sur [`zarith`](https://github.com/ocaml/Zarith), qui fournit des entiers et des rationnels de taille arbitraire. Il n'y a aucun calcul flottant, donc aucune erreur d'arrondi.

> **Projet pédagogique.** La partie cryptographique utilise de petites clés, aucun padding et un générateur aléatoire non sûr. Elle sert à comprendre RSA et ses faiblesses, **pas** à protéger des données réelles. Voir [Limites](#limites).

## Architecture

```
algebre_effective/
├── e_gauss/        # Z[i] : entiers de Gauss
├── r_gauss/        # Q[i] : rationnels de Gauss
├── q_poly/         # Q[X] : polynômes à coefficients rationnels
├── crypto_jouet/   # cryptographie pédagogique
│   ├── arith       #   Euclide étendu, inverse et exponentiation modulaires
│   ├── premiers    #   Miller-Rabin, génération de nombres premiers
│   └── rsa         #   génération de clés, chiffrement, déchiffrement
└── test/           # tests et démonstrations
```

Chaque module expose une interface `.mli` documentée. Les dépendances suivent l'ordre `arith` → `premiers` → `rsa`.

## Fonctionnalités

### Algèbre (partie L2)

**`e_gauss`** : entiers de Gauss Z[i]. Constantes, parties réelle et imaginaire, conjugué, norme, addition, soustraction, multiplication, puissance, conversions.

**`r_gauss`** : rationnels de Gauss Q[i]. Mêmes opérations que `e_gauss`, plus la division et l'inverse.

**`q_poly`** : polynômes Q[X] en représentation creuse (liste triée de couples `(degré, coefficient)`).

- Arithmétique, division euclidienne, évaluation, dérivée, puissance, inverse modulaire.
- Opérateur de différence finie Δ et ses itérés.
- Interpolation de Newton sur la grille des entiers.
- Développement de Taylor de fractions rationnelles P/Q, par méthode directe et par méthode de Newton.

### Cryptographie pédagogique (`crypto_jouet`)

**`arith`** : briques arithmétiques, écrites sans utiliser les fonctions toutes faites de zarith.

- `gcd_ext` : algorithme d'Euclide étendu (coefficients de Bézout).
- `inv_mod` : inverse modulaire.
- `pow_mod` : exponentiation modulaire rapide (square-and-multiply), en O(log e) multiplications.

**`premiers`** : nombres premiers.

- `miller_rabin` : test de primalité probabiliste, avec une erreur inférieure à 4^(-k) pour k témoins.
- `est_premier` : test complet (petits cas puis Miller-Rabin).
- `premier_aleatoire` : génération d'un premier de taille exacte.

**`rsa`** : RSA « manuel » (textbook RSA).

- `generer` : paire de clés avec e = 65537 et d = e⁻¹ mod φ(n).
- `chiffrer` / `dechiffrer` : c = m^e mod n et m = c^d mod n.
- `encoder` / `decoder` : conversion texte ↔ entier (octets en base 256).

### En cours

- Attaques sur petites clés : divisions successives, méthode de Fermat, Pollard rho, avec mesure du temps en fonction de la taille du module.
- Attaque à petit exposant public sans padding, et explication du rôle d'OAEP.
- Partage de secret de Shamir par interpolation sur Z/pZ.

## Compilation et exécution

### Prérequis

- OCaml ≥ 4.14
- [`dune`](https://dune.build/) ≥ 3.17
- [`zarith`](https://github.com/ocaml/Zarith)

```bash
opam install dune zarith
```

### Build et tests

```bash
dune build
dune exec test/main.exe
```

Les tests comparent les fonctions écrites à la main avec celles de zarith (`Z.gcdext`, `Z.invert`, `Z.powm`, `Z.probab_prime`) sur des centaines d'entrées aléatoires, avec une graine fixe pour que les résultats soient reproductibles. Ils sont aussi lancés automatiquement par GitHub Actions à chaque push.

## Exemple

```ocaml
open Crypto_jouet

let () =
  let (pub, priv) = Rsa.generer 64 in
  let m = Rsa.encoder "Bonjour" in
  let c = Rsa.chiffrer pub m in
  print_endline (Rsa.decoder (Rsa.dechiffrer priv c))   (* Bonjour *)
```

## Choix techniques

- **Arithmétique exacte** avec zarith : indispensable en algèbre symbolique comme en cryptographie.
- **Représentation creuse des polynômes** : on ne stocke pas les coefficients nuls.
- **Séparation interface / implémentation** : chaque `.mli` fixe un contrat (préconditions, résultat, exceptions), vérifié par les tests.
- **Tests par oracle** : les implémentations maison sont comparées à zarith.
- **Build reproductible** avec dune et intégration continue avec GitHub Actions.

## Limites

Ce projet **ne doit pas être utilisé pour protéger des données** :

- clés de quelques dizaines de bits, cassables en quelques secondes ;
- RSA sans padding, donc déterministe et malléable ;
- générateur `Random` d'OCaml, prévisible et non cryptographique ;
- calculs en temps non constant, donc vulnérables aux attaques par canaux auxiliaires.

Pour un usage réel, il faut une bibliothèque éprouvée (par exemple [`mirage-crypto`](https://github.com/mirage/mirage-crypto)).

## Contexte

La partie algèbre a été réalisée dans le cadre de l'UE d'Algèbre effective en L2 Informatique à l'Université de Rouen Normandie. Le sujet original est dans [`q_poly/sujet_projet.pdf`](q_poly/sujet_projet.pdf). La partie cryptographique est une extension personnelle du projet.

## Auteurs

- Rayane Graïne ([@RIZIWYX](https://github.com/RIZIWYX))
- Accyl Benadjaoud ([@Aksil1vgb](https://github.com/Aksil1vgb))

## Licence

Distribué sous licence MIT. Voir [`LICENSE`](LICENSE).
