(* semantic.ml *)

module A = Absyn
module T = Type

let rec check_exp (pos, (exp, ty)) =
  match exp with
  | A.BoolExp _ -> ty := Some T.BOOL
  | A.IntExp  _ -> ty := Some T.INT

  | _ -> Error.fatal "unimplemented"

let semantic program =
  check_exp program
