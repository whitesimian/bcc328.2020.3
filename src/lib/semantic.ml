(* semantic.ml *)

module A = Absyn
module T = Type

type entry = [%import: Env.entry]
type env = [%import: Env.env]

(* Set the value in a reference of optional *)

let set reference value =
  reference := Some value;
  value

(* Checking expressions *)

let rec check_exp env (pos, (exp, tref)) =
  match exp with
  | A.BoolExp _ -> set tref T.BOOL
  | A.IntExp  _ -> set tref T.INT
  | A.RealExp _ -> set tref T.REAL
  | A.StringExp _ -> set tref T.STRING
  | A.LetExp (decs, body) -> check_exp_let env pos tref decs body
  | _ -> Error.fatal "unimplemented"

and check_exp_let env pos tref decs body =
  let env' = List.fold_left check_dec env decs in
  let tbody = check_exp env' body in
  set tref tbody

and check_dec env (pos, dec) =
  match dec with
  | _ -> Error.fatal "unimplemented"

let semantic program =
  check_exp Env.initial program
