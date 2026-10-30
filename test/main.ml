open Q_poly

(* ============================================================
   ==================   UTILITAIRES D'AFFICHAGE   =============
   ============================================================ *)

let print_sep () =
  print_string "\n────────────────────────────────────────\n"

(* Affiche un polynome sous sa forme brute : liste de (degre, coeff) *)
let print_poly label p =
  Printf.printf "%s : [" label;
  List.iter (fun (d, c) -> Printf.printf "(%d, %s) " d (Q.to_string c)) p;
  print_string "]\n"

(* Affiche une liste de rationnels *)
let print_qlist label l =
  Printf.printf "%s : [" label;
  List.iter (fun q -> Printf.printf "%s " (Q.to_string q)) l;
  print_string "]\n"

(* Affiche un polynome sous sa forme lisible grace a to_string *)
let show label p = Printf.printf "%-45s : %s\n" label (to_string p)


(* ============================================================
   ==============   PARTIE 1 — Interpolation de Newton   ======
   ============================================================ *)

(* ─── TEST 1 : pow ─────────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 1 — pow\n";
  let x = [(1, Q.one)] in           (* polynome X *)
  print_poly "X^0 (attendu (0,1))" (pow x 0);
  print_poly "X^1 (attendu (1,1))" (pow x 1);
  print_poly "X^2 (attendu (2,1))" (pow x 2);
  print_poly "X^3 (attendu (3,1))" (pow x 3)

(* ─── TEST 2 : delta ───────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 2 — delta\n";
  (* delta(X)   = (X+1) - X     = 1     *)
  (* delta(X^2) = (X+1)^2 - X^2 = 2X+1  *)
  show "delta(X)   (attendu 1)"    (delta [(1, Q.one)]);
  show "delta(X^2) (attendu 1+2X)" (delta [(2, Q.one)])

(* ─── TEST 3 : delta_n ─────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 3 — delta_n\n";
  let x2 = [(2, Q.one)] in
  (* delta^1(X^2)=2X+1 ; delta^2(X^2)=2 ; delta^3(X^2)=0 *)
  show "delta^1(X^2) (attendu 1+2X)" (delta_n x2 1);
  show "delta^2(X^2) (attendu 2)"    (delta_n x2 2);
  show "delta^3(X^2) (attendu 0)"    (delta_n x2 3)

(* ─── TEST 4 : genere_new_list ─────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 4 — genere_new_list\n";
  let l = List.map Q.of_int [1; 3; 6; 10] in
  print_qlist "input          " l;
  print_qlist "diff (att. 2 3 4)" (genere_new_list [] l)

(* ─── TEST 5 : suivant_suite ───────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 5 — suivant_suite\n";
  (* Nombres triangulaires 1,3,6,10  =>  prochain = 15 *)
  let tri = List.map Q.of_int [1; 3; 6; 10] in
  print_qlist "suite" tri;
  Printf.printf "terme suivant (attendu 15) : %s\n"
    (Q.to_string (suivant_suite tri));
  (* Suite arithmetique 2,4,6,8  =>  prochain = 10 *)
  let arith = List.map Q.of_int [2; 4; 6; 8] in
  Printf.printf "suite 2,4,6,8 -> suivant (attendu 10) : %s\n"
    (Q.to_string (suivant_suite arith));
  (* Carres 0,1,4,9,16  =>  prochain = 25 *)
  let carres = List.map Q.of_int [0; 1; 4; 9; 16] in
  Printf.printf "suite 0,1,4,9,16 -> suivant (attendu 25) : %s\n"
    (Q.to_string (suivant_suite carres))

(* ─── TEST 6 : factoriel ───────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 6 — factoriel\n";
  List.iter
    (fun n -> Printf.printf "%d! = %d\n" n (factoriel n))
    [0; 1; 2; 3; 4; 5; 6]

(* ─── TEST 7 : numerateur_newton ───────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 7 — numerateur_newton\n";
  let x = [(1, Q.one)] in
  (* X ; X(X-1) ; X(X-1)(X-2) *)
  show "num_newton 0 (attendu X)"            (numerateur_newton 0 x);
  show "num_newton 1 (attendu -X+X^2)"       (numerateur_newton 1 x);
  show "num_newton 2 (attendu 2X-3X^2+X^3)"  (numerateur_newton 2 x)

(* ─── TEST 8 : pol_newton ──────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 8 — pol_newton\n";
  let pols = pol_newton 4 in
  let nb = Int.sub (List.length pols) 1 in
  (* la liste est rendue dans l'ordre C(X,nb) ; ... ; C(X,0) *)
  List.iteri (fun idx p -> show (Printf.sprintf "C(X,%d)" (Int.sub nb idx)) p) pols

(* ─── TEST 9 : interpol_newton ─────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 9 — interpol_newton\n";
  (* Constante : f(0)=3  =>  3 *)
  show "interp [3]       (attendu 3)"       (interpol_newton [Q.of_int 3]);
  (* Affine : f(0)=0, f(1)=1  =>  X *)
  show "interp [0;1]     (attendu X)"
    (interpol_newton (List.map Q.of_int [0; 1]));
  (* f(0)=0, f(1)=1, f(2)=4  =>  X^2 *)
  show "interp [0;1;4]   (attendu X^2)"
    (interpol_newton (List.map Q.of_int [0; 1; 4]));
  (* Triangulaires 0,1,3,6  =>  X(X-1)/2 = -1/2 X + 1/2 X^2 *)
  show "interp [0;1;3;6] (attendu X(X-1)/2)"
    (interpol_newton (List.map Q.of_int [0; 1; 3; 6]))


(* ============================================================
   ============   PARTIE 2 — Taylor des fractions   ===========
   ============================================================ *)

(* Polynomes utiles *)
let p_one    = [(0, Q.one)]                              (* 1        *)
let p_x      = [(1, Q.one)]                              (* X        *)
let p_1mx    = [(0, Q.one); (1, Q.minus_one)]            (* 1 - X    *)
let p_1px    = [(0, Q.one); (1, Q.one)]                  (* 1 + X    *)
let p_1mx2   = [(0, Q.one); (2, Q.minus_one)]            (* 1 - X^2  *)
let p_1pxpx2 = [(0, Q.one); (1, Q.one); (2, Q.one)]      (* 1+X+X^2  *)

(* ─── TEST 10 — derivee_frac_rat ───────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 10 — derivee_frac_rat\n";
  (* (1/(1-X))' = 1/(1-X)^2  ->  num=1, denom=1-2X+X^2 *)
  let d1 = derivee_frac_rat (p_one, p_1mx) in
  show "(1/(1-X))' num   (attendu 1)"        (fst d1);
  show "(1/(1-X))' denom (attendu 1-2X+X^2)" (snd d1);
  (* (X/(1+X))' = 1/(1+X)^2 *)
  let d2 = derivee_frac_rat (p_x, p_1px) in
  show "(X/(1+X))' num   (attendu 1)"        (fst d2);
  show "(X/(1+X))' denom (attendu 1+2X+X^2)" (snd d2)

(* ─── TEST 11 — test_frac_rat ──────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 11 — test_frac_rat\n";
  Printf.printf "1/(1-X) (attendu true)  : %b\n"
    (test_frac_rat (p_one, p_1mx));
  Printf.printf "X/(1+X) (attendu true)  : %b\n"
    (test_frac_rat (p_x, p_1px));
  (* denom(0)=2, pas de la forme 1+Q *)
  Printf.printf "1/(2+X) (attendu false) : %b\n"
    (test_frac_rat (p_one, [(0, Q.of_int 2); (1, Q.one)]))

(* ─── TEST 12 — eval_0 ─────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 12 — eval_0\n";
  Printf.printf "(1+2X)/(1-X) en 0 (attendu 1) : %s\n"
    (Q.to_string (eval_0 ([(0, Q.one); (1, Q.of_int 2)], p_1mx)));
  Printf.printf "X^2/(1+X)     en 0 (attendu 0) : %s\n"
    (Q.to_string (eval_0 ([(2, Q.one)], p_1px)));
  Printf.printf "(3+X)/(1+X^2) en 0 (attendu 3) : %s\n"
    (Q.to_string (eval_0 ([(0, Q.of_int 3); (1, Q.one)],
                          [(0, Q.one); (2, Q.one)])))

(* ─── TEST 13 — dev1 (methode directe) ─────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 13 — dev1\n";
  show "1/(1-X)   ordre 4 (att. 1+X+X^2+X^3+X^4)" (dev1 4 (p_one, p_1mx));
  show "1/(1+X)   ordre 4 (att. 1-X+X^2-X^3+X^4)" (dev1 4 (p_one, p_1px));
  show "1/(1-X^2) ordre 4 (att. 1+X^2+X^4)"       (dev1 4 (p_one, p_1mx2))

(* ─── TEST 14 — dev_aux1 (methode Newton) ──────────────────── *)
let () =
  print_sep ();
  print_string "TEST 14 — dev_aux1\n";
  show "1/(1-X)   ordre 5 (att. 1+X+...+X^5)"   (dev_aux1 5 (p_one, p_1mx));
  show "1/(1+X)   ordre 5 (att. 1-X+...-X^5)"   (dev_aux1 5 (p_one, p_1px));
  show "1/(1-X^2) ordre 6 (att. 1+X^2+X^4+X^6)" (dev_aux1 6 (p_one, p_1mx2))

(* ─── TEST 15 — dev2 ───────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 15 — dev2\n";
  show "(1+X)/(1-X) ordre 4 (att. 1+2X+2X^2+2X^3+2X^4)"
    (dev2 4 (p_1px, p_1mx));
  show "X/(1-X)     ordre 4 (att. X+X^2+X^3+X^4)"
    (dev2 4 (p_x, p_1mx));
  show "(1+X^2)/(1-X) ordre 3 (att. 1+X+2X^2+2X^3)"
    (dev2 3 ([(0, Q.one); (2, Q.one)], p_1mx))

(* ─── TEST 16 — compose ────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 16 — compose\n";
  show "X^2 o (1+X)    (att. 1+2X+X^2)"  (compose [(2, Q.one)] p_1px);
  show "(1+X) o X^2    (att. 1+X^2)"     (compose p_1px [(2, Q.one)]);
  show "(1+X+X^2) o 2X (att. 1+2X+4X^2)" (compose p_1pxpx2 [(1, Q.of_int 2)]);
  show "(1+X+X^2) o X  (att. 1+X+X^2)"   (compose p_1pxpx2 p_x)

(* ─── TEST 17 — dev_aux2 (methode composition) ─────────────── *)
let () =
  print_sep ();
  print_string "TEST 17 — dev_aux2\n";
  show "1/(1-X)   ordre 5 (att. 1+X+...+X^5)"   (dev_aux2 5 (p_one, p_1mx));
  show "1/(1+X)   ordre 5 (att. 1-X+...-X^5)"   (dev_aux2 5 (p_one, p_1px));
  show "1/(1-X^2) ordre 6 (att. 1+X^2+X^4+X^6)" (dev_aux2 6 (p_one, p_1mx2))

(* ─── TEST 18 — dev3 ───────────────────────────────────────── *)
let () =
  print_sep ();
  print_string "TEST 18 — dev3\n";
  show "(1+X)/(1-X) ordre 4 (att. 1+2X+2X^2+2X^3+2X^4)"
    (dev3 4 (p_1px, p_1mx));
  show "X/(1-X)     ordre 4 (att. X+X^2+X^3+X^4)"
    (dev3 4 (p_x, p_1mx))

(* ─── TEST 19 — coherence dev1 = dev2 = dev3 ───────────────── *)
let () =
  print_sep ();
  print_string "TEST 19 — coherence des 3 methodes\n";
  let cases = [
    ("1/(1-X)",     (p_one, p_1mx),  5);
    ("1/(1+X)",     (p_one, p_1px),  5);
    ("(1+X)/(1-X)", (p_1px, p_1mx),  4);
    ("X/(1-X)",     (p_x,   p_1mx),  4);
    ("1/(1-X^2)",   (p_one, p_1mx2), 6);
  ] in
  List.iter (fun (name, f, n) ->
    let r1 = dev1 n f and r2 = dev2 n f and r3 = dev3 n f in
    let ok12 = equ (purge r1) (purge r2) in
    let ok23 = equ (purge r2) (purge r3) in
    Printf.printf "%-15s ordre %d : dev1=dev2 %b  dev2=dev3 %b\n"
      name n ok12 ok23
  ) cases;
  print_sep ()

(* dune exec test/main.exe *)