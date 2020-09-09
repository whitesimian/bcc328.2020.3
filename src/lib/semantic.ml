(* semantic.ml *)

module A = Absyn
module T = Type

type entry = [%import: Env.entry]
type env = [%import: Env.env]

let rec check_exp {venv; tenv; inloop} (pos, (exp, ty)) =
  match exp with
  | A.BoolExp _ -> ty := Some T.BOOL
  | A.IntExp  _ -> ty := Some T.INT
  | A.RealExp _ -> ty := Some T.REAL
  | _ -> Error.fatal "unimplemented"

let semantic program =
  check_exp Env.initial program
