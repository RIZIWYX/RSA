(* Mini bibliothèque de tests maison
   Chaque fonction reçoit le nombre d'échecs courant et renvoie le nouveau. *)

(* check name ok failures : un test booléen *)
let check name ok failures =
  Printf.printf "[%s] %s\n" (if ok then "OK  " else "FAIL") name;
  if ok then failures else failures + 1

(* guard name f failures : f () doit renvoyer true ;
   une exception compte comme un échec *)
let guard name f failures =
  match f () with
  | ok -> check name ok failures
  | exception e ->
    Printf.printf "[FAIL] %s : exception %s\n" name (Printexc.to_string e);
    failures + 1

(* expect_exn name f failures : succès si f () lève une exception *)
let expect_exn name f failures =
  match f () with
  | _ ->
    Printf.printf "[FAIL] %s : aucune exception\n" name;
    failures + 1
  | exception _ -> check name true failures

(* À appeler en dernier : résumé, puis code de sortie 1 s'il y a des échecs *)
let finish failures =
  Printf.printf "\n%d échec(s)\n" failures;
  if failures > 0 then exit 1
