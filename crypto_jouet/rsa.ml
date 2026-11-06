type cle_publique = { n : Z.t; e : Z.t }
type cle_privee = { pub : cle_publique; d : Z.t; p : Z.t; q : Z.t }

let generer (bits : int) : cle_publique * cle_privee =
  if bits < 8 then invalid_arg "generer: bits < 8";
  let e = Z.of_int 65537 in
  let rec essai () =
    let p = Premiers.premier_aleatoire (bits / 2) in
    let q = Premiers.premier_aleatoire (bits - bits / 2) in
    if Z.equal p q then essai ()
    else
      let n = Z.mul p q in
      let phi = Z.mul (Z.pred p) (Z.pred q) in
      match Arith.inv_mod e phi with
      | None -> essai ()
      | Some d ->
        let pub = { n; e } in
        (pub, { pub; d; p; q })
  in
  essai ()

let chiffrer (pub : cle_publique) (m : Z.t) : Z.t =
  if Z.lt m Z.zero || Z.geq m pub.n then
    invalid_arg "chiffrer: il faut 0 <= m < n";
  Arith.pow_mod m pub.e pub.n

let dechiffrer (priv : cle_privee) (c : Z.t) : Z.t =
  Arith.pow_mod c priv.d priv.pub.n

  let encoder (s : string) : Z.t =
  String.fold_left
    (fun acc c -> Z.add (Z.mul acc (Z.of_int 256)) (Z.of_int (Char.code c)))
    Z.zero s

let decoder (x : Z.t) : string =
  let rec go x acc =
    if Z.equal x Z.zero then acc
    else
      let (q, r) = Z.ediv_rem x (Z.of_int 256) in
      go q (String.make 1 (Char.chr (Z.to_int r)) ^ acc)
  in
  go x ""