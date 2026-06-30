(* Entiers de Gauss *)

(* Type *)

type t = Z.t * Z.t

(* Construction *)

let zero : t = (Z.zero, Z.zero)

let one : t = (Z.one, Z.zero)

let i : t = (Z.zero, Z.one)

let minus_one : t = (Z.minus_one, Z.zero)

let minus_i : t = (Z.zero, Z.minus_one)

let p_re ((a, _) : t) : Z.t = a

let p_im ((_, b) : t) : Z.t = b


let of_ints ((x, y) : int * int) : t = (Z.(~$x), Z.(~$y))

let of_Zs  ((x, y) : Z.t * Z.t) : t = (x, y)

let of_string (s : string) : t option =
    if s = "" then None
  else
  let is_digit c = c >= '0' && c <= '9'
  and is_sign c = c = '-' || c = '+'
  and is_i c = c = 'i' || c = 'I'
  and long = String.length s in
  let rec aux (re, im) n i m =
    if i = long then
      match (m, n) with
      | 0, 1 -> Some (Z.of_string re, Z.(~$1))
      | 8, 1 -> Some (Z.of_string re, Z.of_string (im ^ "1"))
      | 0, 0 | 0, 3 | 1, 1 | 3, 3 | 8, 3 | 3, 4 | 6, 7 | 9, 9 | 2, 10 | 10, 10 
        | 11, 12 | 12, 12 -> Some (Z.of_string re, Z.of_string im)
      | 5, 9 -> Some (Z.of_string re, Z.of_string (im ^ "1"))
      | _ -> None
    else
      match (n, s.[i]) with
      | 0, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 0
      | 0, c when is_i c -> aux (re, im) 1 (i + 1) 0
      | 0, c when is_sign c -> aux (re ^ Char.escaped c, im) 8 (i + 1) 0
      | 1, c when is_digit c -> aux (re, im ^ Char.escaped c) 1 (i + 1) 1
      | 1, c when is_sign c -> 
         if m = 0 || m = 8 then aux (re ^ Char.escaped c, im ^ "1") 2 (i + 1) 1
         else aux (re ^ Char.escaped c, im) 11 (i + 1) 1
      | 2, c when is_digit c -> aux (re ^ Char.escaped c, im) 10 (i + 1) 2
      | 3, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 3
      | 3, c when is_i c -> aux (im, re) 4 (i + 1) 3
      | 3, c when is_sign c -> aux (re, im ^ Char.escaped c) 5 (i + 1) 3
      | 4, c when is_sign c -> aux (re ^ Char.escaped c, im) 2 (i + 1) 4
      | 5, c when is_digit c -> aux (re, im ^ Char.escaped c) 6 (i + 1) 5
      | 5, c when is_i c -> aux (re, im) 9 (i + 1) 5
      | 6, c when is_digit c -> aux (re, im ^ Char.escaped c) 6 (i + 1) 6
      | 6, c when is_i c -> aux (re, im) 7 (i + 1) 6
      | 8, c when is_digit c -> aux (re ^ Char.escaped c, im) 3 (i + 1) 8
      | 8, c when is_i c -> aux (im, re) 1 (i + 1) 8
      | 9, c when is_digit c -> aux (re, im ^ Char.escaped c) 9 (i + 1) 9
      | 10, c when is_digit c -> aux (re ^ Char.escaped c, im) 10 (i + 1) 10
      | 11, c when is_digit c -> aux (re ^ Char.escaped c, im) 12 (i + 1) 11
      | 12, c when is_digit c -> aux (re ^ Char.escaped c, im) 12 (i + 1) 12
      | _ -> None
  in
  aux ("", "") 0 0 0

let of_substring (s : string) (pos : int) (len : int) : t option = 
  of_string (String.sub s pos len)

(* Principales opérations arithmétiques *)

let norm (e : t) : Z.t =
  let a = p_re e and b = p_im e in
  Z.((a * a) + (b * b))

let opp (e : t) : t = (Z.(~-(p_re e)), Z.(~-(p_im e)))

let add (e : t) (f : t) : t =
  (Z.(p_re e + p_re f), Z.(p_im e + p_im f))

let sub (e : t) (f : t) : t =
  (Z.(p_re e - p_re f), Z.(p_im e - p_im f))

let inv (e : t) : t option =
  if e = one then Some e
  else if e = minus_one then Some e
  else if e = i then Some minus_i
  else if e = minus_i then Some i
  else None

let mul (e : t) (f : t) : t =
  let a = p_re e and b = p_im e and c = p_re f and d = p_im f in
  (Z.((a * c) - (b * d)), Z.((a * d) + (b * c)))

(* Conversion *)

let to_ints (e : t) : (int * int) option =
  let a = p_re e and b = p_im e and mi = Z.(~$min_int) and ma = Z.(~$max_int) in
  if a >= mi && a <= ma && b >= mi && b <= ma then Some (Z.to_int a, Z.to_int b)
  else None

let to_string (e : t) : string =
  let a = p_re e and b = p_im e in
  if Z.equal a Z.zero then
    if Z.equal b Z.zero then Z.to_string Z.zero
    else if Z.equal b Z.one then "i"
    else if Z.equal b Z.minus_one then "-i"
    else Z.to_string b ^ "i"
  else if Z.equal b Z.zero then Z.to_string a
  else if Z.equal b Z.one then Z.to_string a ^ "+i"
  else if Z.equal b Z.minus_one then Z.to_string a ^ "-i"
  else if Z.lt b Z.zero then Z.to_string a ^ Z.to_string b ^ "i"
  else Z.to_string a ^ "+" ^ Z.to_string b ^ "i"

(* Égalité *)

let equ (e : t) (f : t) : bool =
  Z.equal (p_re e) (p_re f) && Z.equal (p_im e) (p_im f)

(* Puissance *)

let pow (e : t) (n : int) : t option =
  if n < 0 || equ e zero && n = 0 then None
  else
    let rec aux acc e = function
      | 0 -> Some acc
      | n when n mod 2 = 0 -> aux acc (mul e e) (n / 2)
      | n -> aux (mul acc e) e (n - 1)
    in
    aux one e n

(* Opérateurs préfixes et infixes *)

let ( ~- ) = opp

let ( ~+ ) (e : t) : t = e

let ( + ) = add

let ( - ) = sub

let ( * ) = mul

let ( ** ) = pow

let ( ~$ ) = of_ints

let ( = ) = equ
