(* Entiers de Gauss *)

(* Type *)

type t = Q.t * Q.t

(* Construction *)

let zero : t = Q.zero , Q.zero;;

let one : t = Q.one,Q.zero;;

let i : t = Q.zero,Q.one;;

let minus_one : t = Q.minus_one, Q.zero;;

let minus_i : t = Q.zero, Q.minus_one;;

let p_re ((a, _) : t) : Q.t = a ;;

let p_im ((_, b) : t) : Q.t = b ;;

let of_ints ((x, y) : int * int) : t = Q.of_int(x),Q.of_int(y) ;;

let of_Zs ((x, y) : Z.t * Z.t) : t = Q.(~$$)x , Q.(~$$)y ;;

let of_Qs ((x, y) : Q.t * Q.t) : t = x,y;;

let of_egauss ( e : E_gauss.t) : t = of_Zs(e);;


let of_string (s : string) : t option =
  if s = "" then None
  else
  let is_digit c = c >= '0' && c <= '9'
  and is_sign c = c = '-' || c = '+'
  and is_i c = c = 'i' || c = 'I'
  and is_slash c = c = '/'
  and long = String.length s in
  let rec aux (re, im) n i m =
    if i = long then
      match (m, n) with
      | 0, 1 -> Some (Q.of_string re, Q.(~$1))
      | 8, 1 -> Some (Q.of_string re, Q.of_string (im ^ "1"))
| 0, 0 | 0, 3 | 3, 3 | 8, 3 | 11, 3 | 3, 4 | 6, 7 | 7, 7 | 15, 7 | 2, 10 | 10, 10
        | 12, 13 | 13, 13 | 9, 16 | 16, 16 | 17, 18 | 18, 18 | 1, 19 | 19, 19 
        | 20, 21 | 21, 21 -> Some (Q.of_string re, Q.of_string im)
      | 5, 9 -> Some (Q.of_string re, Q.of_string (im ^ "1"))
      | _ -> None
    else
      match (n, s.[i]) with
      | 0, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 0
      | 0, c when is_i c -> aux (re, im) 1 (i + 1) 0
      | 0, c when is_sign c -> aux (re ^ Char.escaped c, im) 8 (i + 1) 0
      | 1, c when is_digit c -> aux (re, im ^ Char.escaped c) 19 (i + 1) 1
      | 1, c when is_sign c -> aux (re ^ Char.escaped c, im ^ "1") 2 (i + 1) 1
      | 2, c when is_digit c -> aux (re ^ Char.escaped c, im) 10 (i + 1) 2
      | 3, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 3
      | 3, c when is_i c -> aux (im, re) 4 (i + 1) 3
      | 3, c when is_sign c -> aux (re, im ^ Char.escaped c) 5 (i + 1) 3
      | 3, c when is_slash c -> aux (re ^ Char.escaped c, im) 11 (i + 1) 3
      | 4, c when is_sign c -> aux (re ^ Char.escaped c, im) 2 (i + 1) 4
      | 5, c when is_digit c -> aux (re, im ^ Char.escaped c) 6 (i + 1) 5
      | 5, c when is_i c -> aux (re, im) 9 (i + 1) 5
      | 6, c when is_digit c -> aux (re, im ^ Char.escaped c) 6 (i + 1) 6
      | 6, c when is_slash c -> aux (re, im ^ Char.escaped c) 14 (i + 1) 6
      | 6, c when is_i c -> aux (re, im) 7 (i + 1) 6
      | 8, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 8
      | 8, c when is_i c -> aux (im, re) 1 (i + 1) 8
      | 9, c when is_digit c -> aux (re, im ^ Char.escaped c) 16 (i + 1) 9
      | 10, c when is_digit c -> aux (re ^ Char.escaped c, im) 10 (i + 1) 10
      | 10, c when is_slash c -> aux (re ^ Char.escaped c, im) 12 (i + 1) 10
      | 11, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 11
      | 12, c when is_digit c -> aux (re ^ Char.escaped c, im) 13 (i + 1) 12
      | 13, c when is_digit c -> aux (re ^ Char.escaped c, im) 13 (i + 1) 13
      | 14, c when is_digit c -> aux (re, im ^ Char.escaped c) 15 (i + 1) 14
      | 15, c when is_digit c -> aux (re, im ^ Char.escaped c) 15 (i + 1) 15
      | 15, c when is_i c -> aux (re, im) 7 (i + 1) 15
      | 16, c when is_digit c -> aux (re, im ^ Char.escaped c) 16 (i + 1) 16
      | 16, c when is_slash c -> aux (re, im ^ Char.escaped c) 17 (i + 1) 16
      | 17, c when is_digit c -> aux (re, im ^ Char.escaped c) 18 (i + 1) 17
      | 18, c when is_digit c -> aux (re, im ^ Char.escaped c) 18 (i + 1) 18
      | 19, c when is_digit c -> aux (re, im ^ Char.escaped c) 19 (i + 1) 19
      | 19, c when is_slash c -> aux (re, im ^ Char.escaped c) 20 (i + 1) 19
      | 20, c when is_digit c -> aux (re, im ^ Char.escaped c) 21 (i + 1) 20
      | 21, c when is_digit c -> aux (re, im ^ Char.escaped c) 21 (i + 1) 21
      | 21, c when is_sign c -> aux (re ^ Char.escaped c, im) 2 (i + 1) 21
      | _ -> None
  in
  aux ("", "") 0 0 0

let of_substring (s : string) (pos : int) (len : int) : t option = 
  of_string (String.sub s pos len);;

(* Principales opérations arithmétiques *)

let norm (r : t) : Q.t = Q.add (Q.mul (p_re r) (p_re r)) (Q.mul (p_im r) (p_im r));;
let opp (r : t) : t = Q.neg (p_re r),Q.neg (p_im r);;

let add (r : t) (s : t) : t = Q.add (p_re r)(p_re s) ,Q.add (p_im r) (p_im s);;

let sub (r : t) (s : t) : t =  Q.sub (p_re r)(p_re s) ,Q.sub (p_im r) (p_im s);;

let mul (r : t) (s : t) : t =
  let ac = Q.mul (p_re r)(p_re s) in 
  let bd = Q.mul  (p_im r) (p_im s) in
  let ad = Q.mul (p_re r)(p_im s) in
  let bc = Q.mul  (p_im r) (p_re s) in

  (Q.sub ac bd ), (Q.add ad bc) ;;

let div (r : t) (s : t) : t option = 
  if (=) s zero then  None else 
    let ac = Q.mul (p_re r)(p_re s) in 
    let bd = Q.mul  (p_im r) (p_im s) in
    let ad = Q.mul (p_re r)(p_im s) in
    let bc = Q.mul  (p_im r) (p_re s) in 
    let c2 = Q.mul (p_re s) (p_re s) in
    let d2 = Q.mul (p_im s) (p_im s) in
    let den = Q.add c2 d2 in 

    Some ((Q.div (Q.add ac bd ) den) ,  (Q.div (Q.sub bc ad) den));;
let inv (r : t) : t option = 
  if (=) r zero then  None else 
  let den = Q.add (Q.mul (p_re r) (p_re r)) (Q.mul (p_im r) (p_im r)) in 

  Some((Q.div (p_re r) den ), Q.neg  (Q.div (p_im r) den));;
(* Conversion *)

let to_string (r : t) : string =
  let a = p_re r and b = p_im r in
  if Q.equal a Q.zero then
    if Q.equal b Q.zero then Q.to_string Q.zero
    else if Q.equal b Q.one then "i"
    else if Q.equal b Q.minus_one then "-i"
    else Q.to_string b ^ "i"
  else if Q.equal b Q.zero then Q.to_string a
  else if Q.equal b Q.one then Q.to_string a ^ "+i"
  else if Q.equal b Q.minus_one then Q.to_string a ^ "-i"
  else if Q.lt b Q.zero then Q.to_string a ^ Q.to_string b ^ "i"
  else Q.to_string a ^ "+" ^ Q.to_string b ^ "i"

(* Égalité *)

let equ (r : t) (s : t) : bool = (Q.(=) (p_re r)  (p_re s)) && (Q.(=) (p_im r)  (p_im s));;
 
(* Puissance *)

let pow (r : t) (n : int) : t option = 
  if equ r zero && n = 0 then None
  else if n < 0 then None
  else
    let rec aux acc base k =
      if k = 0 then acc
      else if k mod 2 = 0 then aux acc (mul base base) (k / 2)
      else aux (mul acc base) base (k - 1)
    in
    Some (aux one r n)

(* Opérateurs préfixes et infixes *)

let ( ~- ) = opp

let ( ~+ ) (r : t) : t = r

let ( + ) = add

let ( - ) = sub

let ( * ) = mul

let ( / ) = div

let ( ** ) = pow

let ( ~$ ) = of_ints

let ( ~$$ ) = of_Zs

let ( ~$$$ ) = of_egauss

let ( = ) = equ
