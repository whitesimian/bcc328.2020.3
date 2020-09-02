(* absyn.ml *)

type exp =
  | BoolExp   of bool
  | IntExp    of int
  | WhileExp  of (exp * exp)
  [@@deriving show]
