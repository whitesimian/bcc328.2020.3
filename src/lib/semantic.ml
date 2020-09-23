(* semantic.ml *)

module A = Absyn
module S = Symbol
module T = Type

type entry = [%import: Env.entry]
type env = [%import: Env.env]

(* Obtain the location of an ast *)

let loc = Location.loc

(* Reporting errors *)

let undefined loc category id =
  Error.error loc "undefined %s %s" category (S.name id)

let misdefined loc category id =
  Error.error loc "%s is not a %s" (S.name id) category

let type_mismatch loc expected found =
  Error.error loc "type mismatch: found %s, expecting %s"
    (T.show_ty found)
    (String.concat ", " (List.map T.show_ty expected))

(* Searhing in symbol tables *)

let look env category id pos =
  match S.look id env with
  | Some x -> x
  | None -> undefined pos category id

let tylook tenv id pos =
  look tenv "type" id pos

let varlook venv id pos =
  match look venv "variable" id pos with
  | VarEntry t -> t
  | FunEntry _ -> misdefined pos "variable" id

let funlook venv id pos =
  match look venv "function" id pos with
  | VarEntry _ -> misdefined pos "function" id
  | FunEntry (params, result) -> (params, result)

(* Type compatibility *)

let compatible ty1 ty2 pos =
  if not (T.coerceable ty1 ty2) then
    type_mismatch pos [ty2] ty1

let compatible2 ty1 ty2 pos =
  if T.coerceable ty2 ty1 then ty1
  else if T.coerceable ty1 ty2 then ty2
  else Error.error pos "type mismatch: %s and %s" (T.show_ty ty1) (T.show_ty ty2)

let check_bool ty pos = compatible ty T.BOOL pos

let check_int ty pos = compatible ty T.INT pos

let check_real ty pos = compatible ty T.REAL pos

let check_string ty pos = compatible ty T.STRING pos

let check_void ty pos = compatible ty T.VOID pos
(* Set the value in a reference of optional *)

let set reference value =
  reference := Some value;
  value

(* Checking expressions *)

let rec check_exp env (pos, (exp, tref)) =
  match exp with
  | A.BoolExp _ -> set tref T.BOOL
  | A.IntExp  _ -> set tref T.INT
  | A.RealExp _ -> set tref T.REAL
  | A.StringExp _ -> set tref T.STRING
  | A.LetExp (decs, body) -> set tref (check_let_exp env pos decs body)
  | A.VarExp v -> set tref (check_var env v)
  | A.AssignExp (var, exp) -> set tref (check_assign_exp env pos var exp)
  | A.SeqExp exp_list -> set tref (check_seq_exp env pos exp_list)
  | A.IfExp (test, e1, e2) -> set tref (check_if_exp env pos test e1 e2)
  | A.WhileExp (test, body) -> set tref (check_while_exp env pos test body)
  | A.BreakExp -> set tref (check_break_exp env pos)
  | _ -> Error.fatal "unimplemented"

and check_let_exp env _pos decs body =
  let env' = List.fold_left check_dec env decs in
  check_exp env' body

and check_assign_exp env pos var exp =
  compatible (check_exp env exp) (check_var env var) pos;
  T.VOID


and check_seq_exp env _pos exp_list =
  let rec check_sequence = function
    | [] -> T.VOID
    | [e] -> check_exp env e
    | e::rest ->
       ignore (check_exp env e);
       check_sequence rest
  in check_sequence exp_list

and check_if_exp env pos test e1 e2opt =
  check_bool (check_exp env test) (loc test);
  let t1 = check_exp env e1 in
  match e2opt with
  | Some e2 ->
     compatible2 t1 (check_exp env e2) pos
  | None ->
     T.VOID

and check_while_exp env _pos test body =
  check_bool (check_exp env test) (loc test);
  ignore (check_exp {env with inloop = true} body);
  T.VOID

and check_break_exp env pos =
  if env.inloop then
    T.VOID
  else
    Error.error pos "break outside while loop"

(* Checking variables *)

and check_var env (pos, var) =
  match var with
  | A.SimpleVar v -> varlook env.venv v pos
  | _ -> Error.fatal "unimplemented"

(* Checking declarations *)

and check_dec_var env pos ((name, type_opt, init), tref) =
  let tinit = check_exp env init in
  let tvar =
    match type_opt with
    | Some tname ->
       let t = tylook env.tenv tname pos in
       compatible tinit t (loc init);
       t
    | None -> tinit
  in
  ignore (set tref tvar);
  let venv' = S.enter name (VarEntry tvar) env.venv in
  {env with venv = venv'}

and check_dec env (pos, dec) =
  match dec with
  | A.VarDec x -> check_dec_var env pos x
  | _ -> Error.fatal "unimplemented"

(* main semantic analysis function *)

let semantic program =
  check_exp Env.initial program
