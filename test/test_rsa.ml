open Crypto_jouet

let z = Z.of_int
let echecs = ref 0

let check nom ok =
  if ok then Printf.printf "  [ok]   %s\n" nom
  else begin incr echecs; Printf.printf "  [FAIL] %s\n" nom end

let run () =
  print_string "\nETAPE 3 - RSA\n";

  (* Exemple de cours : p = 61, q = 53, e = 17, d = 2753 *)
  let pub = { Rsa.n = z 3233; e = z 17 } in
  let priv = { Rsa.pub; d = z 2753; p = z 61; q = z 53 } in
  check "chiffrer 65 = 2790" (Z.equal (Rsa.chiffrer pub (z 65)) (z 2790));
  check "dechiffrer 2790 = 65" (Z.equal (Rsa.dechiffrer priv (z 2790)) (z 65));

  (* Aller-retour avec une vraie clé générée *)
  Random.init 46;
  let (pub, priv) = Rsa.generer 64 in
  check "n = p * q" (Z.equal pub.n (Z.mul priv.p priv.q));
  let ok = ref true in
  for _ = 1 to 100 do
    let m = Z.random_int pub.n in
    if not (Z.equal (Rsa.dechiffrer priv (Rsa.chiffrer pub m)) m) then ok := false
  done;
  check "100 messages : dechiffrer (chiffrer m) = m" !ok;

  (* Message trop grand : doit être refusé *)
  check "message >= n refusé"
    (match Rsa.chiffrer pub pub.n with
     | _ -> false
     | exception Invalid_argument _ -> true);

  (* Texte *)
  check "encoder \"Hi\" = 18537" (Z.equal (Rsa.encoder "Hi") (z 18537));
  check "decoder 18537 = \"Hi\"" (Rsa.decoder (z 18537) = "Hi");
  check "decoder (encoder s) = s" (Rsa.decoder (Rsa.encoder "Bonjour") = "Bonjour");
  let m = Rsa.encoder "Bonjour" in
  let c = Rsa.chiffrer pub m in
  check "chiffrer puis dechiffrer \"Bonjour\""
    (Rsa.decoder (Rsa.dechiffrer priv c) = "Bonjour");

  (* Bilan : toujours en dernier *)
  if !echecs > 0 then (Printf.printf "%d echec(s)\n" !echecs; exit 1)
  else print_string "Tous les tests RSA passent.\n"