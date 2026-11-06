(**
   RSA jouet (phase 3).

   Projet pédagogique : petites clés, aucun padding, générateur
   aléatoire non sûr. Ne jamais utiliser en production.
*)

(** {1 Types} *)

type cle_publique = { n : Z.t; e : Z.t }
(** Clé publique : le module [n = p*q] et l'exposant public [e]. *)

type cle_privee = { pub : cle_publique; d : Z.t; p : Z.t; q : Z.t }
(** Clé privée : la clé publique associée, l'exposant privé [d]
    et les deux facteurs premiers [p] et [q]. *)

(** {1 Génération} *)

val generer : int -> cle_publique * cle_privee
(** [generer bits] crée une paire de clés avec un module [n] d'environ
    [bits] bits, et [e = 65537].
    @raise Invalid_argument si [bits < 8]. *)

(** {1 Chiffrement} *)

val chiffrer : cle_publique -> Z.t -> Z.t
(** [chiffrer pub m] renvoie [m^e mod n].
    @raise Invalid_argument si [m < 0] ou [m >= n]. *)

val dechiffrer : cle_privee -> Z.t -> Z.t
(** [dechiffrer priv c] renvoie [c^d mod n]. *)