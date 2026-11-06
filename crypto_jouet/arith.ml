

let gcd_ext a b =
  let rec aux r0 u0 v0 r1 u1 v1 =
    if Z.equal r1 Z.zero then (r0,u0,v0)
    else
      let q = Z.div r0 r1 in
      aux r1 u1 v1
        (Z.sub r0 (Z.mul q r1))  
        (Z.sub u0 (Z.mul q u1))                   
         (Z.sub v0 (Z.mul q v1))                   
  in
  let (g, u, v) = aux a Z.one Z.zero b Z.zero Z.one in
  if Z.sign g < 0 then (Z.neg g, Z.neg u, Z.neg v) else (g, u, v)


let inv_mod a n =
  if Z.sign n <= 0 then invalid_arg "inv_mod: n doit etre > 0";
  let (g, u, _) = gcd_ext a n in
  if Z.equal Z.one g then Some  (Z.erem u n)
  else None
  
let pow_mod b e n =
  if Z.sign n <= 0 then invalid_arg "pow_mod: n doit etre > 0";
  if Z.sign e < 0 then invalid_arg "pow_mod: e doit etre >= 0";
  let rec aux result base e =
    if Z.equal e Z.zero then result
    else
      let result =
        if Z.is_odd e then Z.erem (Z.mul result base) n else result
      in
      aux result (Z.erem (Z.mul base base) n) (Z.shift_right e 1)
  in
  aux (Z.erem Z.one n) (Z.erem b n) e