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

(* Returns the variables' types in the function parameters list *)

let rec get_formals lparams acc env pos =
  match lparams with
  | (n, t)::tail -> get_formals tail (acc @ [tylook env.tenv t pos]) env pos
  | [(n, t)]     -> acc @ [tylook env.tenv t pos]
  | []           -> acc

(* Returns the variables' names in the function parameters list *)

let rec get_formals_names lparams acc =
  match lparams with
  | (n, t)::tail -> get_formals_names tail (acc @ [S.name n])
  | [(n, t)]     -> acc @ [S.name n]
  | []           -> acc

(* Checks if item is in the list *)

let inList item lst = List.mem item lst

(* Checks if a variable name was declared more than once in the function parameters' list *)

let rec check_formals_names ln pos =
  match ln with
  | h::t -> if inList h t then Error.error pos "Variable '%s' was declared more than once in the function definition" h
                          else check_formals_names t pos
  | _    -> ()

(* Adds all the parameters variables to the function's body environment *)

let rec add_funvar2env lparam env pos =
   match lparam with
   | (n, t)::tail -> let venv' = S.enter n (VarEntry (tylook env.tenv t pos)) env.venv in
                     let env' = {env with venv = venv'} in
                     add_funvar2env tail env' pos
   | [(n, t)]     -> let venv' = S.enter n (VarEntry (tylook env.tenv t pos)) env.venv in {env with venv = venv'}
   | []           -> env

(* Returns a new environment with the current function *)

let check_params_type funcname lparams type_ret (env, pos) =
  let formals = get_formals lparams [] env pos in
    let venv' = S.enter funcname (FunEntry(formals, type_ret)) env.venv in
    {env with venv = venv'}

(* Checking expressions *)

let rec check_exp env (pos, (exp, tref)) =
  match exp with
  | A.BoolExp _ -> set tref T.BOOL
  | A.IntExp  _ -> set tref T.INT
  | A.RealExp _ -> set tref T.REAL
  | A.StringExp _ -> set tref T.STRING
  | A.LetExp (decs, body) -> check_exp_let env pos tref decs body
  | A.CallExp (n, le) -> check_exp_call env pos tref n le
  | A.NegativeExp (e) -> let v = check_exp env e in 
      begin match v with
        | T.INT | T.REAL -> set tref v
        | _ -> type_mismatch pos T.REAL v
      end

  | A.ExpSeq le -> let t = check_exp_list env le in set tref t

  | A.WhileExp (t, b) -> let env' = {env with inloop = true} in
      ignore(check_exp env' t); ignore(check_exp env' b); set tref T.VOID

  | A.BreakExp -> begin match env.inloop with | true -> set tref T.VOID | _ -> Error.error pos "Break error: break outside loop" end

  | A.VarExp v -> check_var env v tref

  | A.AssignExp (v, e) -> let tv = check_var env v tref in
                          let te = check_exp env e in
                            begin
                              compatible te tv pos;
                              set tref T.VOID
                            end
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
  
  | _ -> Error.fatal "unimplemented"

and check_var env (pos, v) tref =
  match v with
  | A.SimpleVar id -> (let t = varlook env.venv id pos in
                      set tref t)
  | _ -> Error.fatal "unimplemented expression"

and check_exp_list env le =
  match le with
    | []   -> T.VOID
    | [e]  -> check_exp env e
    | h::t -> ignore(check_exp env h); check_exp_list env t 

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

and check_dec_fun env pos ((name, params_list, type_ret, body), tref) =
  let rt     = tylook env.tenv type_ret pos in                                          (* Checking return type *)
  let env'   = check_params_type name params_list rt (env, pos) in                      (* Extended environment including the function *)
  let lnames = get_formals_names params_list [] in
  ignore(check_formals_names lnames pos);                                               (* Checking formals names *)

  let envbody = add_funvar2env params_list env' pos in                                  (* Extended environment of the function's body *)                             
 
  let tbody = check_exp envbody body in                                                 (* Checking if the body's return type matches the function's type *)
    match tbody with
    | rtp when rtp = rt -> ignore(set tref rt); env'
    | _                 -> type_mismatch pos rt tbody

(* Matching parameters' types passed into function call to its required types, as well as the number of parameters *)

and match_fun_param_types lexpr lparam env pos =
  match lexpr, lparam with
  | (eh::et, ph::pt) -> (let etype = check_exp env eh in
                         match etype with
                         | ft when ft = ph -> match_fun_param_types et pt env pos
                         | _               -> type_mismatch pos ph etype
                        )                        
  | [], []           -> ()
  | _                -> Error.error pos "Too many or too few parameters were passed into function's call"

and check_exp_call env pos tref name lexpr =
  let (params, result) = funlook env.venv name pos in  (* Look for function definition: parameter's list and return type *)
  ignore(match_fun_param_types lexpr params env pos);
  set tref result

and check_dec env (pos, dec) =
  match dec with
  | A.VarDec x -> check_dec_var env pos x
  | A.FunDec x -> check_dec_fun env pos x
  | _ -> Error.fatal "unimplemented declaration"

let semantic program =
  check_exp Env.initial program
