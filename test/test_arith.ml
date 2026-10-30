open Testlib

(* Exemple : remplacez par vos fonctions *)
let rec gcd a b = if b = 0 then a else gcd b (a mod b)

let () =
  let f = 0 in
  let f = check "gcd 12 18 = 6" (gcd 12 18 = 6) f in
  let f = check "gcd 17 5 = 1" (gcd 17 5 = 1) f in
  let f = guard "gcd 0 7 = 7" (fun () -> gcd 0 7 = 7) f in
  let f = expect_exn "division par zéro" (fun () -> 1 / 0) f in
  finish f
