(**
   Ensemble des entiers de Gauss

   Cette interface fixe les opérations nécessaires pour une structure 
   algébrique effective correspondant à l'ensemble des entiers de Gauss. 

   L'implantation fait appel au sous-module Z des entiers relatifs de longueur 
   arbitraire de la bibliothèque zarith. 

*)

(** {1 Types} *)

type t = Z.t * Z.t
(** Type pour les entiers de Gauss. *)

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

val p_re : t -> Z.t
(** La partie réelle *)

val p_im : t -> Z.t
(** La partie imaginaire *)

val of_ints : int * int -> t
(** Transforme un couple de type int * int en une valeur de type t. *)

val of_Zs : Z.t * Z.t -> t
(** Transforme un couple de type Z.t * Z.t en une valeur de type t. *)

val of_string : string -> t option
(** Convertit une chaîne de caractère en un entier de Gauss. *)

val of_substring : string -> int -> int -> t option
(** of_substring s pos len est identique à of_string (String.sub s pos len). *)

(** {1 Principales opérations arithmétiques} *)

val norm : t -> Z.t
(** Norme arithmétique. *)

val opp : t -> t
(** Opposé d'un élément. *)

val add : t -> t -> t
(** Addition. *)

val sub : t -> t -> t
(** Soustraction. *)

val inv : t -> t option
(** Inverse s'il existe *)

val mul : t -> t -> t
(** Multiplication. *)

(** {1 Conversion} *)

val to_ints : t -> (int * int) option
(** Transforme une valeur de type egauss en un couple d'entiers. *)

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

val ( ** ) : t -> int -> t option
(** Puissance [pow]. *)

val ( ~$ ) : int * int -> t
(** Conversion d'un couple d'entiers [of_ints]. *)

val ( = ) : t -> t -> bool
(** Identique à equ. *)
