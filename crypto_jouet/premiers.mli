(**
   Nombres premiers

   Cette interface fixe les opérations nécessaires pour tester la primalité
   d'un grand entier avec le test probabiliste de Miller-Rabin.

   L'implantation fait appel au module Z des entiers relatifs de longueur
   arbitraire de la bibliothèque zarith et à la fonction [Arith.pow_mod].
   Les témoins sont tirés avec le générateur [Random] de la bibliothèque
   standard : [Random.init] rend les résultats reproductibles.

*)

(** {1 Test de primalité} *)

val miller_rabin : int -> Z.t -> bool
(** [miller_rabin k n] teste la primalité de [n] avec [k] témoins aléatoires.

    - [false] : [n] est composé, avec certitude ;
    - [true] : [n] est premier avec une probabilité d'erreur inférieure
      à [4^(-k)] (pour un composé, au plus un témoin sur quatre se trompe).

    Les cas [n < 2], [n = 2], [n = 3] et [n] pair sont traités directement.
    Lève [Invalid_argument] si [k < 1].
    Exemple : [miller_rabin 20 (Z.of_int 561) = false]. *)

val est_premier : Z.t -> bool
(** [est_premier n] teste la primalité de [n]. Écarte d'abord les petits cas
    ([n < 2], divisibilité par les premiers jusqu'à 37) puis appelle
    [miller_rabin] avec 20 témoins, soit une erreur inférieure à 10^(-12).

    Exemple : [est_premier (Z.of_int 7919) = true]. *)

(** {1 Génération} *)

val premier_aleatoire : int -> Z.t
(** [premier_aleatoire bits] renvoie un nombre premier aléatoire d'exactement
    [bits] bits, c'est-à-dire dans [[2^(bits-1), 2^bits - 1]].

    On tire un entier aléatoire de [bits] bits, on force le bit de poids fort
    (pour obtenir la taille exacte) et le bit de poids faible (pour qu'il soit
    impair), puis on le teste avec [est_premier]. On recommence tant que le
    test échoue : il faut en moyenne environ [bits * ln 2 / 2] essais.

    Lève [Invalid_argument] si [bits < 2].
    Exemple : [premier_aleatoire 512] renvoie un premier de 512 bits. *)
