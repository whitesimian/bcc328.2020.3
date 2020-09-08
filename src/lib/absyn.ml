(* absyn.ml *)

type symbol = Symbol.symbol
[@@deriving show]


type exp =
  | BoolExp       of bool
  | IntExp        of int
  | RealExp       of float
  | NegativeExp   of lexp
  | BinaryExp     of (lexp * binary_op * lexp)
  | WhileExp      of (lexp * lexp)
  | BreakExp
  | ExpSeq        of lexp list
  | CallExp       of symbol * lexp list
  | VarExp        of lvar
  | LetExp        of ldec list * lexp
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

and var =
  | SimpleVar     of Symbol.symbol  
  [@@deriving show]

and lvar = var Location.loc
  [@@deriving show]

and dec =
  | VarDec        of Symbol.symbol * Symbol.symbol option * lexp

and ldec = dec Location.loc
  [@@deriving show]