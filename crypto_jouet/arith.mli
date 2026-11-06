(**
   Briques arithmétiques pour RSA

   Cette interface fixe les opérations d'arithmétique modulaire nécessaires
   à la construction d'un RSA jouet : algorithme d'Euclide étendu, inverse
   modulaire et exponentiation modulaire rapide.

   L'implantation fait appel au module Z des entiers relatifs de longueur
   arbitraire de la bibliothèque zarith.

*)

(** {1 Algorithme d'Euclide étendu} *)

val gcd_ext : Z.t -> Z.t -> Z.t * Z.t * Z.t
(** [gcd_ext a b] renvoie un triplet [(g, u, v)] tel que
    - [g] est le pgcd de [a] et [b], avec [g >= 0] ;
    - [a * u + b * v = g] (identité de Bézout).

    Les entrées peuvent être négatives ou nulles. Par convention,
    [gcd_ext 0 0 = (0, 1, 0)].
    Le nombre de divisions est en O(log (min |a| |b|)).
    Exemple : [gcd_ext 240 46 = (2, -9, 47)]. *)

(** {1 Inverse modulaire} *)

val inv_mod : Z.t -> Z.t -> Z.t option
(** [inv_mod a n] renvoie [Some x] où [x] est l'inverse de [a] modulo [n],
    c'est-à-dire l'unique [x] dans [[0, n-1]] tel que [a * x] est congru
    à 1 modulo [n]. Renvoie [None] si [a] et [n] ne sont pas premiers
    entre eux (l'inverse n'existe pas).

    [a] peut être négatif ou supérieur à [n].
    Lève [Invalid_argument] si [n <= 0].
    Pour [n = 1], le seul résidu est 0 : [inv_mod a 1 = Some 0].
    Exemple : [inv_mod 17 3120 = Some 2753]. *)

(** {1 Exponentiation modulaire} *)

val pow_mod : Z.t -> Z.t -> Z.t -> Z.t
(** [pow_mod b e n] calcule [b^e mod n] par la méthode square-and-multiply,
    avec un résultat dans [[0, n-1]]. Le nombre de multiplications est en
    O(log e), et les valeurs intermédiaires restent inférieures à [n].

    [b] peut être négatif ou supérieur à [n].
    [pow_mod b 0 n] vaut [1 mod n] : en particulier [pow_mod b 0 1 = 0].
    Lève [Invalid_argument] si [n <= 0] ou [e < 0].
    Exemple : [pow_mod 4 13 497 = 445]. *)
