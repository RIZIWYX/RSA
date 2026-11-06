(* Petits premiers utilisés pour écarter vite la plupart des composés *)
let petits_premiers = [2; 3; 5; 7; 11; 13; 17; 19; 23; 29; 31; 37]

(* decompose m = (s, d) tel que m = 2^s * d avec d impair (m > 0) *)
let decompose m =
  let rec aux s d =
    if Z.is_even d then aux (s + 1) (Z.shift_right d 1) else (s, d)
  in
  aux 0 m

(* temoin_prouve_compose a n s d : vrai si le témoin a prouve que n est composé,
   avec n - 1 = 2^s * d, d impair *)
let temoin_prouve_compose a n s d =
  let n1 = Z.pred n in
  let x = Arith.pow_mod a d n in
  if Z.equal x Z.one || Z.equal x n1 then false
  else
    let rec aux x i =
      if i = 0 then true
      else
        let x = Z.erem (Z.mul x x) n in
        if Z.equal x n1 then false
        else if Z.equal x Z.one then true
        else aux x (i - 1)
    in
    aux x (s - 1)

let miller_rabin k n =
  if k < 1 then invalid_arg "miller_rabin: k doit etre >= 1";
  if Z.lt n (Z.of_int 2) then false
  else if Z.equal n (Z.of_int 2) || Z.equal n (Z.of_int 3) then true
  else if Z.is_even n then false
  else
    let (s, d) = decompose (Z.pred n) in
    (* témoin tiré dans [2, n-2] *)
    let temoin () = Z.add (Z.of_int 2) (Z.random_int (Z.sub n (Z.of_int 3))) in
    let rec tours i =
      i = 0 || (not (temoin_prouve_compose (temoin ()) n s d) && tours (i - 1))
    in
    tours k

let est_premier n =
  let rec essaie = function
    | [] -> miller_rabin 20 n
    | p :: reste ->
      let p = Z.of_int p in
      if Z.equal n p then true
      else if Z.divisible n p then false
      else essaie reste
  in
  if Z.lt n (Z.of_int 2) then false else essaie petits_premiers

let premier_aleatoire (bits : int) : Z.t =
  if bits < 2 then invalid_arg "premier_aleatoire: bits < 2";
  let bit_fort = Z.shift_left Z.one (bits - 1) in
  let rec essai () =
    let x = Z.random_bits bits in
    let x = Z.logor x bit_fort in
    let x = Z.logor x Z.one in
    if est_premier x then x else essai ()
  in
  essai ()
