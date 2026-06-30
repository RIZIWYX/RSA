(**
   Ensemble des polynômes à coefficients rationnels

   Cette interface fixe les opérations nécessaires pour une structure 
   algébrique effective correspondant à l'ensemble des polynômes à coefficients 
   rationnels. 

   L'implantation fait appel au module Q des nombres rationnels de la 
   bibliothèque zarith. 

   Les polynômes sont implantés en représentation creuse. 

*)

(** {1 Types} *)

type t = (int * Q.t) list
(** Type pour les polynômes à coefficients rationnels. Le premier élément du 
    couple est le degré. Le second élément est le coefficient de type Q.t. Les 
    degrés sont positifs et classés en ordre croissant dans la liste. Les 
    coefficients sont non nuls. *)

type point = Q.t * Q.t

type ab = Vide | Noeud of t * ab * ab
    
val is_polynomial : t -> bool
(** Teste si la liste de couples est un polynôme. *)

val purge : t -> t
(** Supprime d'éventuels coefficients nuls. *)

val coeff : int -> t -> Q.t
(** Calcule le coefficient d'un certain degré pour un polynôme. *)

val degree : t -> int
(** Calcule le degré d'un polynôme. *)

val cd : t -> Q.t
(** Calcule le coefficient dominant du polynôme. *)


(** {1 Construction} *)

val zero : t
(** L'élément neutre pour l'addition. *)

val one : t
(** L'élément neutre pour la multipication. *)

val minus_one : t
(** L'élément opposé à l'élément neutre pour la multiplication. *)

(** {1 Principales opérations arithmétiques} *)

val mult_coeff : Q.t -> t -> t
(** Multiplie un polynôme par un coefficient. *)

(**val opp : t -> t**)
(** Opposé d'un élément. *)

val add : t -> t -> t
(** Addition. *)

val sub : t -> t -> t
(** Soustraction. *)

val mult_monome : int -> t -> t
(** multiplie par un monome. *)

val mult_naive : t -> t -> t

(** {1 Conversion} *)

val to_string : t -> string
(** Convertit un élément en une chaîne de caractères. *)

val of_string : string -> t option
(** Convertit une chaîne de caractères en un élément. *)

val mult : t -> t -> t

val renverse : int -> t -> t 

val  inverse_mod : t -> int -> t
val quotient : t -> t -> t
val reste : t -> t -> t
val modulo : t -> int -> t


val eval : t -> Q.t -> Q.t

(** {1 Égalité} *)

val equ : t -> t -> bool
(** Teste l'égalité de deux éléments. *)


val calcule_point : t -> Q.t -> point

val ab_sp : Q.t list -> ab

val print_ab : ab-> unit

val ab_r : t -> Q.t list -> ab

val eval_m : t -> Q.t list -> point list

val liste_points : t ->  Q.t->  int->  Q.t -> point list 

val derivee : t -> t 

val interpolation : point list -> t


(*************************projet*************************)

(** {1 Projet — Partie 1 : Interpolation de Newton} *)

val pow : t -> int -> t
(** [pow p n] calcule le polynôme [p] élevé à la puissance [n]. *)

val delta : t -> t
(** [delta p] applique l'opérateur différence finie : delta(p) = p(X+1) - p(X). *)

val delta_n : t -> int -> t
(** [delta_n p i] applique [i] fois l'opérateur différence finie à [p]. *)

val genere_new_list : Q.t list -> Q.t list -> Q.t list
(** [genere_new_list acc l] calcule la liste des différences successives de [l].
    [acc] est l'accumulateur (passer [[]] pour un appel initial). *)

val suivant_suite : Q.t list -> Q.t
(** [suivant_suite l] prédit le prochain terme de la suite [l]
    par la méthode des différences finies. *)

val factoriel : int -> int
(** [factoriel n] calcule [n!]. *)

val numerateur_newton : int -> t -> t
(** [numerateur_newton n p] calcule le produit tombant p*(p-1)*...*(p-n+1). *)

val pol_newton : int -> t list
(** [pol_newton i] retourne la liste [C(X,i); C(X,i-1); ...; C(X,0)]. *)

val interpol_newton : Q.t list -> t
(** [interpol_newton l] retourne le polynôme interpolateur de Newton
    passant par les points (0,l0), (1,l1), ..., (n,ln). *)

(** {1 Projet — Partie 2 : Développement de Taylor des fractions rationnelles} *)

type frac_rat = t * t
(** Type encodant une fraction rationnelle P/Q : le premier polynôme est le
    numérateur P, le second est le dénominateur Q. *)

val derivee_frac_rat : frac_rat -> frac_rat
(** [derivee_frac_rat f] calcule la dérivée de la fraction [f = P/Q] en
    appliquant la formule (P/Q)' = (P'Q - PQ') / Q^2. Le résultat est rendu
    sous la forme (numérateur, dénominateur). *)

val test_frac_rat : frac_rat -> bool
(** [test_frac_rat f] teste si la fraction [f] est de la forme P/(1+Q) avec
    Q(0) = 0, c'est-à-dire si le dénominateur vaut 1 en 0. *)

val eval_0 : frac_rat -> Q.t
(** [eval_0 f] évalue la fraction [f] en z = 0. Échoue si [f] n'est pas sous
    la forme attendue (cf. {!test_frac_rat}). *)

val dev1 : int -> frac_rat -> t
(** [dev1 n f] calcule le développement de Taylor F_n de la fraction [f] à
    l'ordre [n] par la méthode directe (sommation des 1/i! F^(i)(0) X^i). *)

val dev_aux1 : int -> frac_rat -> t
(** [dev_aux1 n f] calcule le développement de Taylor de 1/(1+Q) à l'ordre [n]
    par la méthode de Newton (inversion modulaire du dénominateur). *)

val dev2 : int -> frac_rat -> t
(** [dev2 n f] calcule le développement de Taylor F_n de [f = P/(1+Q)] à
    l'ordre [n] en multipliant P par l'inverse de (1+Q) tronqué (méthode de
    Newton, cf. {!dev_aux1}). *)

val compose : t -> t -> t
(** [compose p q] calcule la composition P ∘ Q = P(Q), où chaque puissance X^i
    de [p] est remplacée par [q]^i. *)

val dev_aux2 : int -> frac_rat -> t
(** [dev_aux2 n f] calcule le développement de Taylor de 1/(1+Q) à l'ordre [n]
    par composition : on tronque H(-Q) où H = 1 + X + X^2 + ... + X^n. *)

val dev3 : int -> frac_rat -> t
(** [dev3 n f] calcule le développement de Taylor F_n de [f = P/(1+Q)] à
    l'ordre [n] par la méthode de composition (cf. {!dev_aux2}). *)

(* 
(** {1 Opérateurs préfixes et infixes} *)
(** 
val ( ~- ) : t -> t
(** Opposé d'un élément [opp]. *)

val ( ~+ ) : t -> t
(** Identité. *)

val ( + ) : t -> t -> t
(** Addition [add]. *)

val ( - ) : t -> t -> t
(** Subtraction [sub]. *)

val ( = ) : t -> t -> bool
(** Identique à equ. *)
**) *)