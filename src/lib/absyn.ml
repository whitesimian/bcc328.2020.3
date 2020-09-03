(* absyn.ml *)

type exp =
  | BoolExp   of bool
  | IntExp    of int
  | RealExp   of float
  | WhileExp  of (lexp * lexp)
  | BreakExp
  [@@deriving show]

and lexp = exp Location.loc  (* exp anotated with a location *)
  [@@deriving show]
