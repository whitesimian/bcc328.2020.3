(* absyn.ml *)

type exp =
  | BoolExp       of bool
  | IntExp        of int
  | StringExp     of string
  | RealExp       of float
  | NegativeExp   of lexp
  | BinaryExp     of (lexp * binary_op * lexp)
  | WhileExp      of (lexp * lexp)
  | BreakExp
  [@@deriving show]

and lexp = exp Location.loc  (* exp anotated with a location *)
  [@@deriving show]
 
and binary_op = 
  | Plus
  | Minus
  | Times
  | Div
  | Mod
  | Power
  | Equal
  | NotEqual
  | GreaterThan
  | GreaterEqual
  | LowerThan
  | LowerEqual
  | And
  | Or
  [@@deriving show]
