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
  Error.error loc "type mismatch: expected %s, found %s" (T.show_ty expected) (T.show_ty found)

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
    type_mismatch pos ty2 ty1

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
  | A.LetExp (decs, body) -> check_exp_let env pos tref decs body
  | A.BinaryExp (lexp, op, rexp) -> 
      let type_lexp = check_exp env lexp in
      let type_rexp = check_exp env rexp in
      begin match op with
        | A.Plus | A.Minus | A.Times | A.Div | A.Mod | A.Power ->
          begin match type_lexp, type_rexp with
            | T.INT, T.REAL | T.REAL, T.INT | T.REAL, T.REAL  -> set tref T.REAL
            | T.INT, T.INT                                    -> set tref T.INT
            | _                                               -> type_mismatch pos type_lexp type_rexp
          end     

        | A.Equal | A.NotEqual -> compatible type_rexp type_lexp pos; set tref T.BOOL

        | A.GreaterThan | A.GreaterEqual | A.LowerThan | A.LowerEqual ->
          begin match type_lexp with
            | T.INT    -> (match type_rexp with T.INT    -> set tref T.BOOL | _ -> type_mismatch pos T.INT type_rexp)
            | T.REAL   -> (match type_rexp with T.REAL   -> set tref T.BOOL | _ -> type_mismatch pos T.REAL type_rexp)
            | T.STRING -> (match type_rexp with T.STRING -> set tref T.BOOL | _ -> type_mismatch pos T.STRING type_rexp)
          end

        | A.And | A.Or ->
          begin match type_lexp, type_rexp with
            | T.BOOL, T.BOOL -> set tref T.BOOL
            | _ -> (match type_lexp with | T.BOOL -> type_mismatch pos T.BOOL type_rexp | _ -> type_mismatch pos T.BOOL type_lexp)
          end

        | _ -> Error.fatal "unimplemented"
      end

  | A.NegativeExp (e) -> let v = check_exp env e in 
      begin match v with
        | T.INT | T.REAL -> set tref v
        | _ -> type_mismatch pos T.REAL v
      end

  | A.ExpSeq le -> check_exp_list env le tref

  | A.WhileExp (t, b) -> let env' = {env with inloop = true} in
      ignore(check_exp env' t); ignore(check_exp env' b); set tref T.VOID

  | A.BreakExp -> match env.inloop with | true -> set tref T.VOID | _ -> Error.error pos "Break error: break outside loop"

  | _ -> Error.fatal "unimplemented"

and check_exp_list env le tref =
  match le with
    | []   -> set tref T.VOID
    | [e]  -> check_exp env e
    | h::t -> ignore(check_exp env h); check_exp_list env t tref

and check_exp_let env pos tref decs body =
  let env' = List.fold_left check_dec env decs in
  let tbody = check_exp env' body in
  set tref tbody

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

let semantic program =
  check_exp Env.initial program
