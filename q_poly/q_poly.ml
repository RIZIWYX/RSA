type t = (int * Q.t) list

type ab = Vide | Noeud of t * ab * ab

type point = Q.t * Q.t
let zero = [];;

let one = [(0,Q.one)];;

let minus_one = [(0,Q.minus_one)];;
let rec is_polynomial  (p : t) : bool=
    match p with    
        |(_ , a )::[]-> not (Q.equal a Q.zero)
        |(i , a )::(j,b)::q-> if Q.equal a Q.zero || Q.equal b Q.zero || i >= j then false 
                                        else is_polynomial((j,b)::q)
        |[]-> true
;;

let rec equ (p1 : t) (p2 : t) : bool =
    match p1,p2 with
    (i , a )::q , (j,b)::qq -> if i = j && a = b then equ q qq else false
    |[],[]-> true
    |_,_ -> false
;;

let rec  purge (p: t) : t = 
    match p  with
      |(i , a )::q-> if not (Q.equal a Q.zero) then (i , a):: purge q else purge q
      |[]-> [] 
;;

let  rec coeff (j: int ) (p:t) : Q.t = 
    match p with
        |(i , a )::_ when i == j-> a
        |(_, _)::q -> coeff j q
        |[]-> Q.zero
;;

let rec degree (p: t) : int = 
      match p with
        |(i , _ )::[] -> i
        |(_ , _ )::q -> degree q
        |[]-> -1;;
;;

let rec cd (p : t) : Q.t = 
match p with
        |(_ , a )::[] -> a
        |(_ , _ )::q -> cd q
        |[]-> Q.zero;;
;;

let rec mult_coeff (d : Q.t) (p : t ) : t = 
     match p  with
      |(i , a )::q-> (i , Q.mul a  d ):: mult_coeff d q 
      |[]-> [] 
;;


let  rec add (p1: t) (p2:t) : t = 
    match p1,p2 with
      |(i , a )::q , (j , b)::qq -> if i = j then  if (Q.add a  b )  = Q.zero then (add q  qq)  else (i, Q.add a  b) ::(add q  qq)
                                    else if i < j then (i , a)::(add q  ((j , b)::qq)) 
                                    else (j , b )::(add ((i , a)::q)  qq)
      |[],q -> q
      |q,[] -> q
;;

let  rec sub (p1: t) (p2:t) : t = 
    match p1,p2 with
      |(i , a )::q , (j , b)::qq -> if i = j then if (Q.sub a  b )  = Q.zero then (sub q  qq)  else (i, Q.sub a  b) ::(sub q  qq)        
                                    else if i < j then (i , a )::(sub q  ((j , b)::qq) )
                                      else (j , Q.neg b )::(sub ((i , a)::q)  qq)
      |[],q -> mult_coeff Q.minus_one q
      |q,[] -> q
;;
 
let rec  mult_monome (j: int)  (p:t) : t = 
match p  with
      |(i , a )::q-> ( i + j , a  ):: mult_monome j q 
      |[]-> [] 
;;

let rec  mult_naive (p1: t)  (p2:t) : t = 
match p1  with
      |(i , a)::q-> add (mult_coeff a (mult_monome i p2)) (mult_naive q p2) 
      |[] -> []
;;

let to_string (p : t) : string =
  let rec aux acc =      
    function
    | [] -> acc
    | (n, c) :: p when n = 0 -> aux (acc ^ Q.to_string c) p
    | (n, c) :: p when n = 1 && Q.(c = Q.one) && acc = "" -> aux "X" p
    | (n, c) :: p when n = 1 && Q.(c = Q.one) -> aux (acc ^ "+X") p
    | (n, c) :: p when n = 1 && Q.(c = Q.minus_one) -> aux (acc ^ "-X") p
    | (n, c) :: p when n = 1 && Q.(c < Q.zero)
      -> aux (acc ^ (Q.to_string c) ^ "X") p
    | (n, c) :: p when n = 1 && acc = "" -> aux ((Q.to_string c) ^ "X") p
    | (n, c) :: p when n = 1 -> aux (acc ^ "+" ^ (Q.to_string c) ^ "X") p
    | (n, c) :: p when Q.(c = Q.one)       && acc = ""
      -> aux ("X^" ^ (string_of_int n)) p
    | (n, c) :: p when Q.(c = Q.one)
      -> aux (acc ^ "+X^" ^ (string_of_int n)) p
    | (n, c) :: p when Q.(c = Q.minus_one)
      -> aux (acc ^ "-X^" ^ (string_of_int n)) p
    | (n, c) :: p when Q.(c < Q.zero)
      -> aux (acc ^ (Q.to_string c) ^ "X^" ^ (string_of_int n)) p
    | (n, c) :: p when acc = ""
      -> aux ((Q.to_string c) ^ "X^" ^ (string_of_int n)) p
    | (n, c) :: p
      -> aux (acc ^ "+" ^ (Q.to_string c) ^ "X^" ^ (string_of_int n)) p
  in (if p = []
      then "0"
      else aux "" p)
let of_string (s : string) : t option =

  let long = String.length s
  in (if long = 0
      then Some []
      else
        (let is_digit c = c >= '0' && c <= '9'
         and is_as c = c = '+' || c = '-'
         and is_sl c = c = '/'
         and is_X c = c = 'X'
         and is_pow c = c = '^'
         in (let rec aux p coef exp n i =
               if i = long
               then
                 (match n with
                 | 0 -> Some p
                 | 1 -> Some (add p [0, Q.of_string coef])
                 | 2 | 3 | 6 -> None
                 | 4 -> Some (add p [0,  Q.of_string coef])
                 | 5 -> Some (add p [1,  Q.of_string coef])
                 | 7 -> Some (add p [int_of_string exp,  Q.of_string coef])
                 | _ -> None)
               else
                 match (n,s.[i]) with
                 | 0, c when is_digit c -> aux p (coef ^ (Char.escaped c)) exp
                                             1 (i + 1)
                 | 0, c when is_as c -> aux p (Char.escaped c) exp 2 (i + 1)
                 | 0, c when is_X c -> aux p "1" exp 5 (i + 1)
                 | 1, c when is_digit c -> aux p (coef ^ (Char.escaped c)) exp
                                             1 (i + 1)
                 | 1, c when is_sl c -> aux p (coef ^ (Char.escaped c)) exp 3
                                          (i + 1)
                 | 1, c when is_as c -> aux (add p [0, Q.of_string coef])
                                          (Char.escaped c) exp 2 (i + 1)
                 | 1, c when is_X c -> aux p coef exp 5 (i + 1)
                 | 2, c when is_digit c -> aux p (coef ^ (Char.escaped c)) exp
                                             1 (i + 1)
                 | 2, c when is_X c -> aux p (coef ^ "1") exp 5 (i + 1)
                 | 3, c when is_digit c -> aux p (coef ^ (Char.escaped c)) exp
                                             4 (i + 1)
                 | 4, c when is_digit c -> aux p (coef ^ (Char.escaped c)) exp
                                             4 (i + 1)
                 | 4, c when is_as c -> aux (add p [0, Q.of_string coef])
                                          (Char.escaped c) exp 2 (i + 1)
                 | 4, c when is_X c -> aux p coef exp 5 (i + 1)
                 | 5, c when is_pow c -> aux p coef exp 6 (i + 1)
                 | 5, c when is_as c -> aux (add p [1, Q.of_string coef])
                                          (Char.escaped c) "" 2 (i + 1)
                 | 6, c when is_digit c -> aux p coef (exp ^ (Char.escaped c))
                                             7 (i + 1)
                 | 7, c when is_digit c -> aux p coef (exp ^ (Char.escaped c))
                                             7 (i + 1)
                 | 7, c when is_as c -> aux (add p [int_of_string exp,
                                                    Q.of_string coef])
                                          (Char.escaped c) "" 2 (i + 1)
                 | _ -> None
             in aux zero "" "" 0 0)));;

let casse (p : t)  (i: int) :  t * t = 
let rec aux p p1 p2 = 
  match p with  
    []-> List.rev p1, List.rev p2
    |(j,a)::q -> if j < i then  aux q ((j,a)::p1) p2 else aux q p1  ((j-i,a)::p2) 
  in aux p [] []
;;

let choisir_coupure  (d1: int) (d2 :int) :int =
  let m = max d1 d2 in 
    if m mod 2 == 0 then m else m + 1 
;;

let rec add_degre (p : t) (i : int) : t = 
    match p with 
      []->[]
      |(j,a)::q -> (i+j,a)::(add_degre q i)
;;

let rec mult (p1 : t) (p2 : t) : t = 
    let c = choisir_coupure (degree(p1)) (degree(p2)) in 
    if c < 20 then mult_naive p1 p2 else 
    let a0,a1  = casse p1 (c/2) in 
    let b0,b1  = casse p2  (c/2) in 
    let c0 = mult a0 b0 in
    let c2 = mult a1 b1 in
    let c1 =  sub (sub (mult (add a0 a1) (add b0 b1)) c0) c2 in

    add (add c0 (add_degre c1 (c/2))) (add_degre c2 c) ;;

let  renverse (i: int )(p : t) : t  =
if i < degree p then failwith "erreur"
  else
   List.rev (List.map (fun (j, a) -> (i - j, a)) p)  ;;


let rec modulo (p:t) (i:int) : t = 
  match p with 
    []->[]
    |(j,a)::q-> if j >= i then [] else (j,a) ::(modulo  q i )
;;


let inverse_mod (p:t) (n:int) : t =
  match p with
  | [] -> failwith "inverse_mod: polynome nul"
  | (0,a0)::_ ->
      if a0 = Q.zero then failwith "inverse_mod: constant nul";

      let rec aux g k =
        if k >= n then modulo g n
        else
          let k2 = min (2*k) n in
          let pg = modulo (mult p g) k2 in
          let two = [(0, Q.of_int 2)] in
          let tmp = sub two pg in
          let g' = modulo (mult g tmp) k2 in
          aux g' k2
      in

      let g0 = [(0, Q.inv a0)] in
             aux g0 1

  | _ -> failwith "inverse_mod: polynome mal forme"
;;


let quotient (p1:t) (p2:t) : t =
  if degree p1 < degree p2 then []
  else
    let n = degree p1 in
    let m = degree p2 in
    let d = n - m in

    let p1r = renverse n p1 in
    let p2r = renverse m p2 in

    let qrev =
      mult
        (modulo p1r (d + 1))
        (inverse_mod p2r (d + 1))
    in

    renverse d (modulo qrev (d + 1)) 
;; 
let reste (p1:t) (p2:t) : t =
  let q = quotient p1 p2 in
 sub p1 (mult p2 q);;


let eval (p : t) (x : Q.t) : Q.t =
  let rec pow_x k =
    if k = 0 then Q.one else Q.mul x (pow_x (k - 1))
  in
  List.fold_left (fun acc (i, c) -> Q.add acc (Q.mul c (pow_x i))) Q.zero p

let calcule_point (p:t) (x:Q.t) : point =
      x,eval p x;;

let split (l : Q.t list) : (Q.t list * Q.t list) =
  let rec aux acc1 acc2 = function
    | []          -> List.rev acc1, List.rev acc2
    | a :: []     -> List.rev (a :: acc1), List.rev acc2
    | a :: b :: r -> aux (a :: acc1) (b :: acc2) r
  in aux [] [] l

let rec ab_sp (l : Q.t list) : ab = 
  match l with 
    a::[]-> Noeud([(0,Q.neg a); (1, Q.one)],Vide,Vide)
    |b -> let q1,q2 = split b
                in let a1 = ab_sp q1 in
                let val1 = match a1 with 
                             Vide -> failwith "erreur" 
                              |Noeud(q,_,_)-> q
                in let a2 = ab_sp q2  in
                let val2 = match a2 with 
                             Vide -> failwith "erreur" 
                              |Noeud(q,_,_)-> q
              in Noeud((mult val1 val2),a1,a2)
;;
let rec print_ab (t:ab) =
  match t with
  | Vide -> print_string "."
  | Noeud(v, g, d) ->
      Printf.printf "(%s " (to_string v);
      print_ab g; print_string " "; print_ab d;
      print_string ")";;

let ab_r (p:t) (l : Q.t list) : ab =
  let asp = ab_sp l in 
  let rec aux q s = 
    match s with 
    | Vide -> Vide
    | Noeud(v, Vide, Vide) ->
        let r = reste q v in
        Noeud(r, Vide, Vide)       
    | Noeud(v, a1, a2) ->
        let r = reste q v in
        Noeud(r, aux q a1, aux q a2)
  in aux p asp


let to_point_list (d : Q.t list) (l : Q.t list) : (Q.t * Q.t) list =
  let rec aux acc t1 t2 =
    match t1, t2 with
    | a::q, b::qq -> aux ((a,b)::acc) q qq
    | [], [] -> List.rev acc
    | _ -> failwith "erreur"
  in aux [] d l
;;


let to_list (arbre: ab) : Q.t list =
  let rec aux a acc =
    match a with
    | Noeud (r, Vide, Vide) ->
        let v = if r = [] then Q.zero else cd r in
        v :: acc
    | Noeud (_, ab1, Vide)  -> aux ab1 acc
    | Noeud (_, Vide, ab2)  -> aux ab2 acc
    | Noeud (_, ab1, ab2)   -> aux ab2 (aux ab1 acc)
    | Vide                  -> acc
  in
  List.rev (aux arbre []) 

let rec leaves_order (l : Q.t list) : Q.t list =
  match l with
  | [] -> []
  | [_] -> l
  | _ ->
      let l1, l2 = split l in
      leaves_order l1 @ leaves_order l2
;;

let eval_m (p : t) (l : Q.t list) : point list =
  let len = List.length l in
  if len >= degree p then
    let arbre = ab_r p l in
    let ys = to_list arbre in
    let xs = leaves_order l in
    to_point_list xs ys
  else
    List.map (fun x -> (x, eval p x)) l
;;

 let liste_points (p : t) (x0 : Q.t) (n : int) (d : Q.t) : point list =
    let rec aux acc x k =
      if k = 0 then List.rev acc
      else aux ((x, eval p x) :: acc) (Q.add x d) (k - 1)
  in aux [] x0 n

let derivee (p : t) : t = 
  let rec aux pp acc =  
match pp with 
|[] ->List.rev acc
|(0,_)::q -> aux q acc
|(i,c)::q -> aux q (((i - 1 , Q.mul (Q.of_int i) c))::acc) in
aux p []
;;

let  x_list (p : point list) : Q.t list = 
  let rec aux  pp acc  = 
    match pp with
      []->  List.rev acc
      | (a,_)::q -> aux q (a::acc) 
in aux p [];;

let omega_sans_i (xl : Q.t list) (xi : Q.t) : t =
  List.fold_left (fun acc xj ->
    if Q.equal xj xi then acc
    else mult acc [(0, Q.neg xj); (1, Q.one)]
  ) [(0, Q.one)] xl
;;

let interpolation (p : point list) : t =
  let xl = x_list p in
  let e1 = ab_sp xl in
  let omega = match e1 with
    | Vide -> failwith "erreur"
    | Noeud(v, _, _) -> v
  in
  let omega' = derivee omega in
  let e3 = eval_m omega' xl in
  List.fold_left (fun acc (xi, yi) ->
    let wi = List.assoc xi e3 in
    let ai = Q.div yi wi in
    add acc (mult_coeff ai (omega_sans_i xl xi))
  ) [] p
;;


(*************************projet*************************)

(***********************exo1*************************)

let rec pow (t: t) (d:int) : t=
  match d with 
   0-> [0,Q.one]
  |n -> mult (pow t (n-1)) t
;;

let delta (t: t) : t =
  let px = [(0,Q.one);(1,Q.one)]in
  let rec aux acc (p: t) =
    match p with
    []->  acc
    |(d,c)::q -> aux (add acc (mult_coeff c (pow px d))) q 
  in sub (aux [] t) t
;;


let delta_n (p: t) (i:int) : t= 
  let rec aux acc k = 
    match k with
      0->  acc
     |n-> aux (delta acc) (n-1)
  in aux p i
;;

let rec genere_new_list (acc: Q.t list) (l: Q.t list) = 
    match l with
      [] | _::[] -> List.rev acc
     |a::b::q -> genere_new_list ((Q.sub b a)::acc) (b::q);;



let suivant_suite (ql: Q.t list) : Q.t =
  let rec aux l =
    match l with
    | [] -> failwith "suivant_suite: liste vide"
    | [a] -> a   
    | _ ->
      let diff = genere_new_list [] l in
      let suiv_diff = aux diff in
      let dernier = List.nth l (List.length l - 1) in
      Q.add dernier suiv_diff
  in aux ql
;;

let rec factoriel (n : int) : int =
  match n with
  0-> 1
  |n -> n * factoriel (n-1)
;;

let rec numerateur_newton (n : int) (p: t) : t  =
  match n with 
  0-> p 
  |n -> mult p (numerateur_newton (n-1) (sub p [0,Q.one]))

;;
let rec  pol_newton (i: int): t list =
  match i with 
   0-> [[(0,Q.one)]]
  |n -> (quotient (numerateur_newton (n-1) ([1,Q.one])) [0,(Q.of_int(factoriel n))]) :: pol_newton (n-1)
;;

let interpol_newton (ql: Q.t list) : t =
  let n = List.length ql in
  let l = List.rev (pol_newton (n-1)) in
  let rec diff_iter liste k =
    if k = 0 then List.hd liste
    else diff_iter (genere_new_list [] liste) (k-1)
  in
  let rec aux acc l1 k =
    match l1 with
    | [] -> acc
    | a::q ->
      let coeff = diff_iter ql k in
      if Q.equal coeff Q.zero
      then aux acc q (k+1)
      else aux (add acc (mult_coeff coeff a)) q (k+1)
  in purge (aux [] l 0)
;;


(***********************exo2*************************)
type frac_rat = t * t;;

let derivee_frac_rat (f : frac_rat) : frac_rat = 
  let p = (fst f) in 
  let q = (snd f) in
  let deriv_p = derivee p in 
  let deriv_q =  derivee q in 
  let q_2 =  pow (snd f) 2 in 
  let num =  sub (mult deriv_p q )   (mult deriv_q p ) in

   num,q_2
;;

let test_frac_rat (f: frac_rat) : bool =
  Q.equal (eval (snd f) Q.zero) Q.one
;;

let eval_0 (f : frac_rat) : Q.t = 

  if test_frac_rat f then
   let p = (fst f) in 
  let q = (snd f) in
  let num = eval p Q.zero in 
  let den = eval q Q.zero in
    Q.div num den
  else failwith "";;


let dev1 (i : int) (fract : frac_rat) : t =
  let rec aux acc f n =
    if n > i then acc
    else
      let f1 = Q.inv (Q.of_int (factoriel n)) in
      let ev_0 = eval_0 f in
      let new_num = Q.mul f1 ev_0 in
      let num = mult_coeff new_num [(n, Q.one)] in
      aux (add acc num) (derivee_frac_rat f) (n+1)
  in
  aux [] fract 0
;;
let dev_aux1 (n: int) (f: frac_rat) : t =
  inverse_mod (snd f) (n+1)
;;
let dev2 (i: int) (f : frac_rat) : t =
  modulo (mult (dev_aux1 i f) (fst f)) (i+1)


let compose (p: t) (q: t) : t =
  let rec aux acc pp =
    match pp with
    | [] -> acc
    | (i, c) :: qq ->
      let qi = pow q i in
      let term = mult_coeff c qi in
      aux (add acc term) qq
  in aux [] p
;;

 let dev_aux2 (i: int) (f: frac_rat) : t =
  (* H_i = 1 + X + X^2 + ... + X^i *)
  let rec build_H k =
    if k > i then []
    else (k, Q.one) :: build_H (k+1)
  in
  let h = build_H 0 in
  (* Q = denom - 1, puisque denom = 1 + Q *)
  let q = sub (snd f) one in
  let neg_q = mult_coeff Q.minus_one q in
  modulo (compose h neg_q) (i+1)
;;

let dev3 (i: int) (f: frac_rat) : t =
  let inv = dev_aux2 i f in
  modulo (mult (fst f) inv) (i+1)
;;
