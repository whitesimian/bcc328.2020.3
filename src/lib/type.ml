(* types.ml *)

(* internal type representation *)
type ty =
  | VOID
  | BOOL
  | INT
[@@deriving show]

(* type compatibility *)
let coerceable a b =
  match a, b with
  | VOID , VOID -> true
  | BOOL , BOOL -> true
  | INT  , INT  -> true
  | _           -> false

(* general tree from internal type representation *)
let tree_of = function
  | VOID -> Tree.mkt "VOID" []
  | BOOL -> Tree.mkt "BOOL" []
  | INT  -> Tree.mkt "INT"  []

