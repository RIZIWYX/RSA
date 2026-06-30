(**
   Ensemble des rationnels de Gauss

   Cette interface fixe les opérations nécessaires pour une structure 
   algébrique effective correspondant à l'ensemble des rationnels de Gauss. 

   L'implantation fait appel au sous-module R des nombres rationnels de 
   grandeur arbitraire de la bibliothèque zarith. 

*)

(** {1 Types} *)

type t = Q.t * Q.t
(** Type pour les rationnels de Gauss. *)

(** {1 Construction} *)

val zero : t
(** L'élément neutre pour l'addition. *)

val one : t
(** L'élément neutre pour la multipication. *)

val i : t
(** L'unité imaginaire. *)

val minus_one : t
(** L'élément opposé à l'élément neutre pour la multiplication. *)

val minus_i : t
(** L'élément opposé à l'unité imaginaire. *)

val p_re : t -> Q.t
(** La partie réelle *)

val p_im : t -> Q.t
(** La partie imaginaire *)

val of_ints : int * int -> t
(** Transforme un couple de type int * int en une valeur de type t. *)

val of_Zs : Z.t * Z.t -> t
(** Transforme un couple de type Z.t * Z.t en une valeur de type t. *)

val of_Qs : Q.t * Q.t -> t
(** Transforme un couple de type Q.t * Q.t en une valeur de type t. *)

val of_egauss : E_gauss.t -> t
(** Transforme une valeur de type E_gauss.t en une valeur de type t. *)

val of_string : string -> t option
(** Convertit une chaîne de caractère en un élément. *)

val of_substring : string -> int -> int -> t option
(** of_substring s pos len est identique à of_string (String.sub s pos len). *)

(** {1 Principales opérations arithmétiques} *)

val norm : t -> Q.t
(** Norme arithmétique. *)

val opp : t -> t
(** Opposé d'un élément. *)

val add : t -> t -> t
(** Addition. *)

val sub : t -> t -> t
(** Soustraction. *)

val mul : t -> t -> t
(** Multiplication. *)

val div : t -> t -> t option
(** Division. *)

val inv : t -> t option
(** Inverse *)

(** {1 Conversion} *)

val to_string : t -> string
(** Convertit un élément en une chaîne de caractères. *)

(** {1 Égalité} *)

val equ : t -> t -> bool
(** Teste l'égalité de deux éléments. *)

(** {1 Puissance} *)

val pow : t -> int -> t option



(** Puissance d'un élément. *)

(** {1 Opérateurs préfixes et infixes} *)

val ( ~- ) : t -> t
(** Opposé d'un élément [opp]. *)

val ( ~+ ) : t -> t
(** Identité. *)

val ( + ) : t -> t -> t
(** Addition [add]. *)

val ( - ) : t -> t -> t
(** Subtraction [sub]. *)

val ( * ) : t -> t -> t
(** Multiplication [mul]. *)

val ( / ) : t -> t -> t option
(** Division [div]. *)

val ( ** ) : t -> int -> t option
(** Puissance [pow]. *)

val ( ~$ ) : int * int -> t
(** Conversion d'un couple d'entiers [of_ints]. *)

val ( ~$$ ) : Z.t * Z.t -> t
(** Conversion d'un couple d'entiers de longueur arbitraire [of_Zs]. *)

val ( ~$$$ ) : E_gauss.t  -> t
(** Conversion d'un entier de Gauss [of_egauss]. *)

val ( = ) : t -> t -> bool
(** Identique à equ. *)
