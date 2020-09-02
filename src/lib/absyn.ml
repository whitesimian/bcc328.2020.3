(* absyn.ml *)

type exp =
  | BoolExp   of bool
  | IntExp    of int
  | RealExp   of float
  | WhileExp  of (exp * exp)
  | BreakExp
  [@@deriving show]
