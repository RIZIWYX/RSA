open Testlib
open Crypto_jouet

let z = Z.of_int

(* Crible d'Ératosthène : tableau de booléens jusqu'à [limite] *)
let crible limite =
  let est_p = Array.make (limite + 1) true in
  est_p.(0) <- false;
  est_p.(1) <- false;
  for i = 2 to limite do
    if est_p.(i) then begin
      let j = ref (i * i) in
      while !j <= limite do
        est_p.(!j) <- false;
        j := !j + i
      done
    end
  done;
  est_p

let test_cas_connus f =
  let f = check "est_premier 0 = false" (not (Premiers.est_premier (z 0))) f in
  let f = check "est_premier 1 = false" (not (Premiers.est_premier (z 1))) f in
  let f = check "est_premier 2 = true" (Premiers.est_premier (z 2)) f in
  let f = check "est_premier 3 = true" (Premiers.est_premier (z 3)) f in
  let f = check "est_premier 4 = false" (not (Premiers.est_premier (z 4))) f in
  let f = check "est_premier -7 = false" (not (Premiers.est_premier (z (-7)))) f in
  let f = check "est_premier 7919 = true" (Premiers.est_premier (z 7919)) f in
  let f = check "miller_rabin 20 13 = true" (Premiers.miller_rabin 20 (z 13)) f in
  let f = check "miller_rabin 20 15 = false" (not (Premiers.miller_rabin 20 (z 15))) f in
  let f = check "miller_rabin 20 5 = true (plus petit n sans cas particulier)"
      (Premiers.miller_rabin 20 (z 5)) f in
  expect_exn "miller_rabin 0 13 : exception"
    (fun () -> Premiers.miller_rabin 0 (z 13)) f

(* Les nombres de Carmichael trompent Fermat mais pas Miller-Rabin *)
let test_carmichael f =
  List.fold_left
    (fun f c ->
       check (Printf.sprintf "Carmichael %d est composé" c)
         (not (Premiers.miller_rabin 20 (z c))) f)
    f [561; 1105; 1729; 2465; 2821; 6601; 8911]

let test_grands f =
  let mersenne127 = Z.pred (Z.shift_left Z.one 127) in
  let f = check "2^127 - 1 (Mersenne) est premier"
      (Premiers.est_premier mersenne127) f in
  let f = check "2^127 + 1 est composé"
      (not (Premiers.est_premier (Z.succ (Z.shift_left Z.one 127)))) f in
  let f = check "2^127 - 1 fois 3 est composé"
      (not (Premiers.est_premier (Z.mul mersenne127 (z 3)))) f in
  check "produit de deux grands premiers est composé"
    (not (Premiers.est_premier (Z.mul mersenne127 (z 7919)))) f

(* Comparaison au crible sur [0, 10000], et à Z.probab_prime sur un échantillon *)
let test_oracles f =
  let limite = 10000 in
  let est_p = crible limite in
  let f = check "est_premier = crible d'Ératosthène sur [0, 10000]"
      (let ok = ref true in
       for n = 0 to limite do
         if Premiers.est_premier (z n) <> est_p.(n) then ok := false
       done;
       !ok) f
  in
  let f = check "miller_rabin 20 = crible sur [5, 10000]"
      (let ok = ref true in
       for n = 5 to limite do
         if Premiers.miller_rabin 20 (z n) <> est_p.(n) then ok := false
       done;
       !ok) f
  in
  check "est_premier = Z.probab_prime sur 500 entiers aléatoires de 40 bits"
    (let ok = ref true in
     for _ = 1 to 500 do
       let n = Z.succ (Z.random_bits 40) in
       if Premiers.est_premier n <> (Z.probab_prime n 25 <> 0) then ok := false
     done;
     !ok) f

let () =
  Random.init 42;
  let f = 0 in
  let f = test_cas_connus f in
  let f = test_carmichael f in
  let f = test_grands f in
  let f = test_oracles f in
  finish f
