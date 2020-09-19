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
  | (_, t)::tail -> get_formals tail (acc @ [tylook env.tenv t pos]) env pos
  | []           -> acc

(* Returns the variables' names in the function parameters list *)

let rec get_formals_names lparams acc =
  match lparams with
  | (n, _)::tail -> get_formals_names tail (acc @ [S.name n])
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
  | _ -> Error.fatal "unimplemented expression"

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

and check_var env (pos, var) =
  match var with
  | A.SimpleVar v -> varlook env.venv v pos
  | _ -> Error.fatal "unimplemented"

let semantic program =
  check_exp Env.initial program
