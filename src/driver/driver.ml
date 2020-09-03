(* driver *)

(* get and show all tokens from lexical buffer *)
let scan lexbuf =
  let rec go () =
    let tok = Lexer.token lexbuf in
    Format.printf
      "%a %s\n"
      Location.pp_location (Location.curr_loc lexbuf)
      (Lexer.show_token tok);
    match tok with
    | Parser.EOF -> ()
    | _ -> go ()
  in
  go ()


let main () =
  (* parse command line arguments *)
  Cmdline.parse ();

  (* create lexical buffer *)
  let lexbuf = Lexing.from_channel (Cmdline.get_input_channel ()) in
  Lexer.set_filename lexbuf (Cmdline.get_input_filename ());

  (* print the tokens *)
  try
    (* scan lexbuf *)
    let ast = Parser.program Lexer.token lexbuf in
    Format.printf "%s\n" (Absyn.show_lexp ast)
  with
  | Error.Error (loc, msg) ->
     Format.printf "%a error: %s\n" Location.pp_location loc msg;
     exit 1
  | Parser.Error ->
     Format.printf "%a error: syntax\n" Location.pp_position lexbuf.Lexing.lex_curr_p;
     exit 2

let () = main ()
