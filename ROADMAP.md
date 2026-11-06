# Roadmap RSA jouet - algebre_effective

## Vue d'ensemble

Le projet transforme la bibliothèque d'algèbre de L2 en un RSA jouet complet, attaqué sur de petites clés, en 7 phases d'environ 4 à 6 semaines au total (quelques heures par semaine). Chaque phase suit la même boucle : idée mathématique, interface `.mli` documentée, première version, correction, tests, commit.

**Objectif final** : un dépôt GitHub propre qui montre qu'on sait implémenter des primitives cryptographiques, les casser quand elles sont mal paramétrées, et expliquer pourquoi la vraie crypto utilise de grandes clés et du padding.

### Technologies

| Outil                      | Rôle dans le projet                          | Ce qu'il faut savoir                                                                                                                                                                             |
| -------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| OCaml (>= 4.14)            | Langage de tout le projet                    | Fonctions récursives, pattern matching, `option`, exceptions, modules et signatures                                                                                                              |
| zarith (`Z`, `Q`)          | Entiers et rationnels de taille arbitraire   | `Z.add`, `Z.mul`, `Z.ediv`, `Z.erem`, `Z.shift_right`, `Z.is_odd`, `Z.random_bits`, `Z.of_string` ; `Z.gcdext`, `Z.invert`, `Z.powm`, `Z.probab_prime` servent seulement d'oracle dans les tests |
| dune                       | Build, bibliothèques, exécutables            | Un fichier `dune` par dossier, `(library ...)`, `(executable ...)`, `dune build`, `dune exec`                                                                                                    |
| Git + GitHub               | Historique et vitrine                        | Un commit par étape terminée, messages clairs, README soigné                                                                                                                                     |
| odoc (optionnel)           | Documentation HTML générée depuis les `.mli` | `dune build @doc`                                                                                                                                                                                |
| GitHub Actions (optionnel) | Lancer les tests à chaque push               | Workflow avec `ocaml/setup-ocaml`                                                                                                                                                                |

### Architecture cible

```
algebre_effective/
├── e_gauss/  r_gauss/  q_poly/   # existant (L2)
├── crypto_jouet/
│   ├── arith.ml(i)      # Euclide étendu, inverse, exponentiation
│   ├── premiers.ml(i)   # Miller-Rabin, génération
│   ├── rsa.ml(i)        # clés, chiffrement, déchiffrement
│   ├── attaques.ml(i)   # divisions, Fermat, Pollard rho, e petit
│   ├── chrono.ml(i)     # mesure du temps
│   └── shamir.ml(i)     # bonus, partage de secret
├── test/
│   ├── main.ml          # lance toutes les suites
│   └── test_*.ml        # une suite par module
└── demo/
    └── demo_rsa.ml      # démo lisible pour le README
```

Règle de dépendance : `arith` ne dépend de rien, `premiers` dépend d'`arith`, `rsa` des deux, `attaques` et `shamir` des trois. On code donc dans cet ordre.

## Phase 0 - Mise en place (1 soirée)

But : un projet qui compile, avec la bibliothèque `crypto_jouet` vide et un système de tests qui signale les échecs.

- [ ] Vérifier `opam switch list`, puis `opam install dune zarith` ; `dune build` et `dune exec test/main.exe` doivent passer sur le projet existant.
- [ ] Créer une branche `git checkout -b rsa-jouet` pour ne pas casser la version L2.
- [ ] Ajouter `crypto_jouet/dune` : `(library (name crypto_jouet) (libraries zarith))`.
- [ ] Ajouter `crypto_jouet` aux `libraries` de `test/dune`.
- [ ] Écrire un petit module de tests maison (`check`, `guard`, compteur d'échecs, `exit 1` si échec) - c'est ce que contient déjà `test_arith.ml` du squelette.
- [ ] Corriger le warning 33 (`open R_gauss` inutilisé) plutôt que de le masquer.

**Concept : séparation interface / implémentation.** Le `.mli` est un contrat : il dit ce que la fonction promet (préconditions, résultat, exceptions) sans dire comment. Les tests vérifient le contrat, pas le code.

**Concept : tests par oracle.** Pour vérifier `pow_mod`, on compare à `Z.powm` sur des centaines d'entrées aléatoires. Une graine fixe (`Random.init 42`) rend les échecs reproductibles.

**Commit** : `chore: bibliothèque crypto_jouet et infrastructure de tests`.

## Phase 1 - Briques arithmétiques (3 à 4 jours)

Module `arith`. Squelette et tests déjà fournis.

**Euclide étendu.** On divise successivement : r(i+1) = r(i-1) - q(i)·r(i). En parallèle on garde u(i), v(i) tels que r(i) = a·u(i) + b·v(i), avec les mêmes récurrences, en partant de (1, 0) et (0, 1). Le dernier reste non nul est le pgcd g, et ses coefficients vérifient a·u + b·v = g (Bézout). Complexité : O(log min(a, b)) divisions.

**Inverse modulaire.** Si pgcd(a, n) = 1, alors a·u ≡ 1 mod n : u réduit dans [0, n-1] est l'inverse. Sinon il n'existe pas. C'est ainsi qu'on calcule la clé privée d.

**Exponentiation rapide (square-and-multiply).** On lit e en binaire ; à chaque bit on met la base au carré, et quand le bit vaut 1 on multiplie dans l'accumulateur, tout modulo n. Coût : O(log e) multiplications au lieu de e.

```ocaml
val gcd_ext : Z.t -> Z.t -> Z.t * Z.t * Z.t
val inv_mod : Z.t -> Z.t -> Z.t option
val pow_mod : Z.t -> Z.t -> Z.t -> Z.t
```

Pièges : `Z.rem` garde le signe du dividende, utiliser `Z.erem` pour un résultat dans [0, n-1] ; penser à `pow_mod b 0 1 = 0`.

Tests : exemples connus (pgcd(240, 46) = 2, 17⁻¹ mod 3120 = 2753, 4^13 mod 497 = 445), entrées négatives, cas nuls, 500 cas aléatoires comparés à zarith.

**Commit** : `feat(arith): Euclide étendu, inverse et exponentiation modulaires`.

## Phase 2 - Nombres premiers (3 à 4 jours)

Module `premiers`.

**Pourquoi pas les divisions ?** Tester un nombre de 512 bits par divisions demanderait environ 2^256 opérations. Il faut un test probabiliste.

**Petit théorème de Fermat.** Si p est premier et a non divisible par p, a^(p-1) ≡ 1 mod p. Si ça échoue, n est composé ; mais certains composés (nombres de Carmichael, comme 561) passent le test pour presque tous les a.

**Miller-Rabin.** On écrit n - 1 = 2^s · d avec d impair. Pour un témoin a, on calcule x = a^d mod n. Si x = 1 ou x = n - 1, a ne prouve rien. Sinon on met x au carré jusqu'à s - 1 fois : si on tombe sur n - 1, a ne prouve rien ; sinon n est composé. Un composé trompe au plus 1/4 des témoins, donc k tours donnent une erreur inférieure à 4^(-k).

**Génération.** Tirer un nombre aléatoire de b bits, forcer le bit de poids fort (taille exacte) et le bit de poids faible (impair), tester ; recommencer sinon. Il faut en moyenne environ ln(2^b)/2 essais.

```ocaml
val miller_rabin : ?tours:int -> Z.t -> bool
val est_premier : Z.t -> bool          (* petits cas + MR *)
val premier_aleatoire : bits:int -> Z.t
```

Tests : premiers et composés jusqu'à 10 000 (comparés à un crible d'Ératosthène), nombres de Carmichael 561, 1105, 1729, cas 0, 1, 2, 3, premier de Mersenne 2^127 - 1, taille exacte des premiers générés.

Concept sécurité : `Random` d'OCaml n'est **pas** cryptographiquement sûr. Le noter dans le README ; une vraie implémentation lirait `/dev/urandom`.

**Commit** : `feat(premiers): test de Miller-Rabin et génération de premiers`.

## Phase 3 - RSA jouet (3 jours)

Module `rsa`.

**L'idée.** On choisit deux premiers p, q, on pose n = pq et φ(n) = (p-1)(q-1). On prend e premier avec φ(n) (souvent 65537) et d = e⁻¹ mod φ(n). Chiffrer : c = m^e mod n. Déchiffrer : m = c^d mod n. Ça marche car ed = 1 + kφ(n) et, par le théorème d'Euler, m^(ed) ≡ m mod n.

**Pourquoi c'est sûr (à grande taille).** Retrouver d demande φ(n), donc la factorisation de n. Personne ne sait factoriser efficacement un n de 2048 bits.

```ocaml
type cle_publique = { n : Z.t; e : Z.t }
type cle_privee = { n : Z.t; d : Z.t; p : Z.t; q : Z.t }
val generer : ?e:Z.t -> bits:int -> cle_publique * cle_privee
val chiffrer : cle_publique -> Z.t -> Z.t   (* exige 0 <= m < n *)
val dechiffrer : cle_privee -> Z.t -> Z.t
val encoder : string -> Z.t                  (* octets -> entier *)
val decoder : Z.t -> string
```

Points de réalisation : regénérer si pgcd(e, φ) ≠ 1 ou si p = q ; refuser un message m >= n (`Invalid_argument`) ; encoder une chaîne en entier octet par octet (base 256).

Bonus : déchiffrement par **CRT** (théorème des restes chinois) avec dp, dq, qinv, environ 4 fois plus rapide.

Tests : exemple de cours (p = 61, q = 53, e = 17, d = 2753, m = 65 → c = 2790), aller-retour sur 100 messages aléatoires, messages 0 et 1, message >= n refusé, chaîne de texte encodée puis retrouvée.

**Commit** : `feat(rsa): génération de clés, chiffrement et déchiffrement`.

## Phase 4 - Attaques par factorisation (1 semaine)

Modules `attaques` et `chrono`. On attaque **ses propres clés** générées avec de petites tailles.

**Divisions successives.** Tester tous les diviseurs jusqu'à √n. Coût O(√n) : faisable jusqu'à environ 40 à 50 bits de module.

**Méthode de Fermat.** Si p et q sont proches, n = a² - b² avec a = (p+q)/2 proche de √n. On part de a = ⌈√n⌉ et on augmente a jusqu'à ce que a² - n soit un carré parfait b², d'où p = a - b, q = a + b. Instantané quand |p - q| est petit, même sur 1024 bits. Outils : `Z.sqrt`, `Z.perfect_square`, ou sa propre racine entière par Newton.

**Pollard rho.** On itère f(x) = x² + c mod n. Modulo p (inconnu), la suite boucle après environ √p pas (paradoxe des anniversaires). Avec l'algorithme de Floyd (lièvre et tortue), on calcule pgcd(|x - y|, n) jusqu'à trouver un facteur. Coût environ n^(1/4).

```ocaml
val divisions_successives : Z.t -> (Z.t * Z.t) option
val fermat : ?max_iter:int -> Z.t -> (Z.t * Z.t) option
val pollard_rho : ?c:Z.t -> Z.t -> (Z.t * Z.t) option
val casser : cle_publique -> (Z.t * Z.t) -> cle_privee   (* reconstruit d *)
```

**Mesure du temps.** `Unix.gettimeofday` (ajouter `unix` aux libraries) ou `Sys.time`. Pour chaque taille de module de 20 à 100 bits, moyenne sur plusieurs clés, résultat en CSV (`bits,methode,secondes`). Tracer la courbe (gnuplot ou tableur) et la mettre dans le README.

Tests : n premier ou n = 1 → `None` ; n pair ; n = p² ; Fermat sur p et q écartés → échec dans la limite d'itérations ; p·q = n vérifié ; une clé cassée déchiffre bien.

**Commit** : `feat(attaques): factorisation et mesures de temps`.

## Phase 5 - Attaque e petit sans padding, puis OAEP (3 jours)

**L'attaque.** Avec e = 3 et un message court tel que m³ < n, on a c = m³ exactement. Donc m = racine cubique entière de c. Écrire `racine_entiere : Z.t -> int -> Z.t` (dichotomie ou Newton) et vérifier que r^e = c.

**Variante de Håstad (bonus).** Le même message envoyé à 3 destinataires avec e = 3 et des modules différents : le CRT reconstruit m³ mod n1·n2·n3, qui vaut m³ exactement, puis racine cubique.

**Pourquoi le padding.** RSA « manuel » est déterministe (même message → même chiffré) et malléable (c·2^e déchiffre en 2m). OAEP mélange le message à un aléa via des fonctions de hachage (Feistel à deux tours) avant d'exponentier : le message devient gros, chaque chiffrement est différent, et toute modification est détectée. PKCS#1 v1.5 a été cassé par l'attaque de Bleichenbacher (1998).

Réalisation : démo qui casse un message court avec e = 3 ; démo de malléabilité ; section du README expliquant OAEP. Implémenter OAEP est facultatif (bibliothèque `digestif` pour le hachage).

**Commit** : `feat(attaques): attaque e petit et démonstration de malléabilité`.

## Phase 6 - Bonus : partage de secret de Shamir (3 à 4 jours)

**L'idée.** Pour partager un secret s entre n personnes avec seuil k : choisir un polynôme P de degré k-1 sur Z/pZ avec P(0) = s et des coefficients aléatoires. Chaque personne reçoit (i, P(i)). Avec k points on reconstruit P par interpolation, donc s = P(0) ; avec k-1 points, toutes les valeurs de s restent possibles (sécurité parfaite).

**Le lien avec le code existant.** `interpol_newton` de `q_poly` travaille dans Q. Sur Z/pZ, les divisions deviennent des multiplications par `inv_mod`. Deux options : généraliser `q_poly` avec un foncteur paramétré par un corps, ou écrire une interpolation dédiée dans `shamir`.

```ocaml
val partager : p:Z.t -> k:int -> n:int -> Z.t -> (Z.t * Z.t) list
val reconstruire : p:Z.t -> (Z.t * Z.t) list -> Z.t
```

Tests : k parts quelconques parmi n redonnent s ; k-1 parts ne suffisent pas ; k = 1 et k = n ; secret 0 ; erreur si deux parts ont le même x.

**Commit** : `feat(shamir): partage de secret par interpolation sur Z/pZ`.

## Phase 7 - Finalisation (2 à 3 jours)

- [ ] Programme `demo/demo_rsa.ml` : génère une clé, chiffre un texte, casse une petite clé avec chaque attaque, affiche les temps.
- [ ] README : présentation, architecture, fonctionnalités, commandes (`dune build`, `dune exec test/main.exe`, `dune exec demo/demo_rsa.exe`), graphique des temps, section **Limites** (clés minuscules, `Random` non cryptographique, temps non constant, pas de padding réel : ne jamais utiliser en production).
- [ ] Aucun warning à la compilation.
- [ ] Optionnel : GitHub Actions avec badge dans le README.
- [ ] Fusionner la branche, taguer `v1.0`, épingler le dépôt sur le profil GitHub.

## Planning indicatif

| Semaine | Contenu                   | Livrable                               |
| ------- | ------------------------- | -------------------------------------- |
| 1       | Phase 0 + Phase 1         | Tests `arith` au vert                  |
| 2       | Phase 2 + Phase 3         | Chiffrement / déchiffrement d'un texte |
| 3       | Phase 4                   | Trois attaques + CSV de temps          |
| 4       | Phase 5                   | Démo e = 3 et section OAEP             |
| 5       | Phase 6 (bonus) + Phase 7 | README final, tag v1.0                 |

## Pour le CV et GitHub

- Implémentation en OCaml d'un RSA pédagogique (Euclide étendu, exponentiation modulaire, Miller-Rabin) sur entiers multiprécision zarith.
- Attaques sur clés faibles : divisions successives, Fermat, Pollard rho, attaque à petit exposant ; mesure de la complexité en fonction de la taille du module.
- Partage de secret de Shamir par interpolation de Newton sur Z/pZ ; tests automatisés (dune).

Description du dépôt : « Bibliothèque OCaml d'algèbre exacte étendue en RSA jouet, avec attaques sur petites clés et partage de secret de Shamir. Projet pédagogique, ne pas utiliser en production. »

## À savoir expliquer en entretien

- Pourquoi RSA fonctionne (Euler, ed ≡ 1 mod φ(n)) et pourquoi sa sécurité repose sur la factorisation.
- Pourquoi l'exponentiation rapide est indispensable, et pourquoi une implémentation à temps non constant fuit des informations.
- Pourquoi Miller-Rabin est probabiliste, et ce que signifie une erreur de 4^(-k).
- Le coût de chaque attaque (√n, n^(1/4)) et pourquoi 2048 bits reste hors de portée.
- Pourquoi p et q doivent être indépendants (Fermat) et pourquoi RSA « manuel » est dangereux (déterminisme, malléabilité, e petit) ; ce qu'apportent OAEP et le cas Bleichenbacher.
- La différence entre sécurité calculatoire (RSA) et sécurité parfaite (Shamir).
- Les choix d'ingénierie : interfaces `.mli`, tests par oracle avec graine fixe, une bibliothèque par responsabilité.
