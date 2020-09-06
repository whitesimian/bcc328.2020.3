(* absyn.ml *)

type exp =
  | BoolExp       of bool
  | IntExp        of int
  | RealExp       of float
  | NegativeExp   of lexp
  | PlusExp       of (lexp * lexp)
  | MinusExp      of (lexp * lexp)
  | TimesExp      of (lexp * lexp)
  | DivExp        of (lexp * lexp)
  | ModExp        of (lexp * lexp)
  | PowExp        of (lexp * lexp)
  | WhileExp      of (lexp * lexp)
  | BreakExp
  [@@deriving show]

and lexp = exp Location.loc  (* exp anotated with a location *)
  [@@deriving show]
