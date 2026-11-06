open Testlib
open Crypto_jouet

let z = Z.of_int
let some_z x = Some (z x)

(* Vrai si l'identité de Bézout et g >= 0 sont vérifiées *)
let bezout_ok a b =
  let (g, u, v) = Arith.gcd_ext a b in
  Z.sign g >= 0 && Z.equal (Z.add (Z.mul a u) (Z.mul b v)) g

(* Entier aléatoire dans [-bound, bound] *)
let rand_z bound = z (Random.int (2 * bound + 1) - bound)

let test_gcd_ext f =
  let g_of a b = let (g, _, _) = Arith.gcd_ext (z a) (z b) in g in
  let f = check "gcd_ext 240 46 : pgcd = 2" (Z.equal (g_of 240 46) (z 2)) f in
  let f = check "gcd_ext 240 46 = (2, -9, 47)"
      (Arith.gcd_ext (z 240) (z 46) = (z 2, z (-9), z 47)) f in
  let f = check "gcd_ext 17 3120 : pgcd = 1" (Z.equal (g_of 17 3120) Z.one) f in
  let f = check "gcd_ext 0 0 = (0, 1, 0)"
      (Arith.gcd_ext Z.zero Z.zero = (Z.zero, Z.one, Z.zero)) f in
  let f = check "gcd_ext 5 0 : pgcd = 5" (Z.equal (g_of 5 0) (z 5)) f in
  let f = check "gcd_ext 0 5 : pgcd = 5" (Z.equal (g_of 0 5) (z 5)) f in
  let f = check "gcd_ext -240 46 : pgcd = 2" (Z.equal (g_of (-240) 46) (z 2)) f in
  let f = check "gcd_ext 240 -46 : pgcd = 2" (Z.equal (g_of 240 (-46)) (z 2)) f in
  let f = check "gcd_ext -240 -46 : pgcd = 2" (Z.equal (g_of (-240) (-46)) (z 2)) f in
  let f = check "gcd_ext -1 5 : pgcd = 1" (Z.equal (g_of (-1) 5) Z.one) f in
  let f = check "gcd_ext 7 7 : pgcd = 7" (Z.equal (g_of 7 7) (z 7)) f in
  check "gcd_ext Bézout sur 500 cas aléatoires (signes quelconques)"
    (let ok = ref true in
     for _ = 1 to 500 do
       let a = rand_z 100000 and b = rand_z 100000 in
       let (g, _, _) = Arith.gcd_ext a b in
       if not (bezout_ok a b && Z.equal g (Z.gcd a b)) then ok := false
     done;
     !ok) f

let test_inv_mod f =
  let f = check "inv_mod 17 3120 = Some 2753"
      (Arith.inv_mod (z 17) (z 3120) = some_z 2753) f in
  let f = check "inv_mod 3 7 = Some 5" (Arith.inv_mod (z 3) (z 7) = some_z 5) f in
  let f = check "inv_mod 4 8 = None (pgcd 4)" (Arith.inv_mod (z 4) (z 8) = None) f in
  let f = check "inv_mod 0 7 = None" (Arith.inv_mod Z.zero (z 7) = None) f in
  let f = check "inv_mod 3 1 = Some 0" (Arith.inv_mod (z 3) Z.one = some_z 0) f in
  let f = check "inv_mod -1 5 = Some 4" (Arith.inv_mod (z (-1)) (z 5) = some_z 4) f in
  let f = check "inv_mod -3 7 = Some 2" (Arith.inv_mod (z (-3)) (z 7) = some_z 2) f in
  let f = check "inv_mod 20 7 = Some 6 (a > n)" (Arith.inv_mod (z 20) (z 7) = some_z 6) f in
  let f = expect_exn "inv_mod 3 0 : exception" (fun () -> Arith.inv_mod (z 3) Z.zero) f in
  let f = expect_exn "inv_mod 3 -7 : exception" (fun () -> Arith.inv_mod (z 3) (z (-7))) f in
  check "inv_mod : a * x = 1 mod n et x dans [0, n-1], 500 cas aléatoires"
    (let ok = ref true in
     for _ = 1 to 500 do
       let a = rand_z 100000 and n = z (1 + Random.int 100000) in
       match Arith.inv_mod a n with
       | Some x ->
         if not (Z.equal (Z.erem (Z.mul a x) n) (Z.erem Z.one n)
                 && Z.sign x >= 0 && Z.lt x n)
         then ok := false
       | None ->
         (* pas d'inverse <=> pgcd <> 1, sauf pour n = 1 *)
         if Z.equal (Z.gcd a n) Z.one then ok := false
     done;
     !ok) f

let test_pow_mod f =
  let f = check "pow_mod 4 13 497 = 445"
      (Z.equal (Arith.pow_mod (z 4) (z 13) (z 497)) (z 445)) f in
  let f = check "pow_mod 2 10 1000 = 24"
      (Z.equal (Arith.pow_mod (z 2) (z 10) (z 1000)) (z 24)) f in
  let f = check "pow_mod 5 0 7 = 1"
      (Z.equal (Arith.pow_mod (z 5) Z.zero (z 7)) Z.one) f in
  let f = check "pow_mod 5 0 1 = 0"
      (Z.equal (Arith.pow_mod (z 5) Z.zero Z.one) Z.zero) f in
  let f = check "pow_mod 0 0 7 = 1"
      (Z.equal (Arith.pow_mod Z.zero Z.zero (z 7)) Z.one) f in
  let f = check "pow_mod 0 5 7 = 0"
      (Z.equal (Arith.pow_mod Z.zero (z 5) (z 7)) Z.zero) f in
  let f = check "pow_mod 7 5 1 = 0"
      (Z.equal (Arith.pow_mod (z 7) (z 5) Z.one) Z.zero) f in
  let f = check "pow_mod -2 3 5 = 2 (b négatif)"
      (Z.equal (Arith.pow_mod (z (-2)) (z 3) (z 5)) (z 2)) f in
  let f = check "pow_mod 12 2 5 = 4 (b > n)"
      (Z.equal (Arith.pow_mod (z 12) (z 2) (z 5)) (z 4)) f in
  let f = check "pow_mod 2 1000 grand module = Z.powm"
      (let n = Z.pow (z 10) 40 in
       Z.equal (Arith.pow_mod (z 2) (z 1000) n) (Z.powm (z 2) (z 1000) n)) f in
  let f = expect_exn "pow_mod 2 -1 7 : exception"
      (fun () -> Arith.pow_mod (z 2) (z (-1)) (z 7)) f in
  let f = expect_exn "pow_mod 2 3 0 : exception"
      (fun () -> Arith.pow_mod (z 2) (z 3) Z.zero) f in
  let f = expect_exn "pow_mod 2 3 -5 : exception"
      (fun () -> Arith.pow_mod (z 2) (z 3) (z (-5))) f in
  check "pow_mod = Z.powm sur 500 cas aléatoires"
    (let ok = ref true in
     for _ = 1 to 500 do
       let b = rand_z 1000000
       and e = z (Random.int 100000)
       and n = z (1 + Random.int 1000000) in
       if not (Z.equal (Arith.pow_mod b e n) (Z.powm b e n)) then ok := false
     done;
     !ok) f

(* Mini RSA : chiffrer puis déchiffrer redonne le message *)
let test_rsa f =
  let p = z 61 and q = z 53 in
  let n = Z.mul p q in                                  (* 3233 *)
  let phi = Z.mul (Z.pred p) (Z.pred q) in              (* 3120 *)
  let e = z 17 in
  match Arith.inv_mod e phi with
  | None -> check "RSA : clé privée calculable" false f
  | Some d ->
    let f = check "RSA : d = 2753" (Z.equal d (z 2753)) f in
    check "RSA : déchiffrer (chiffrer m) = m pour tout m < n"
      (let ok = ref true in
       for m = 0 to 3232 do
         let c = Arith.pow_mod (z m) e n in
         if not (Z.equal (Arith.pow_mod c d n) (z m)) then ok := false
       done;
       !ok) f

let () =
  Random.init 42;
  let f = 0 in
  let f = test_gcd_ext f in
  let f = test_inv_mod f in
  let f = test_pow_mod f in
  let f = test_rsa f in
  finish f
