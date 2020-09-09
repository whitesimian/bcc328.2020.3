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
  | A.BoolExp _   -> set tref T.BOOL
  | A.IntExp  _   -> set tref T.INT
  | A.RealExp _   -> set tref T.REAL
  | A.StringExp _ -> set tref T.STRING
  | _ -> Error.fatal "unimplemented"

let semantic program =
  check_exp Env.initial program
