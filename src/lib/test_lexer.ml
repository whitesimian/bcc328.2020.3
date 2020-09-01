(* expect tests for the scanner *)

module L = Lexing

let scan_string s =
  let lexbuf = L.from_string s in
  let rec go () =
    let tok = Lexer.token lexbuf in
    Format.printf
      "%a %s\n%!"
      Location.pp_location (Location.curr_loc lexbuf)
      (Lexer.show_token tok);
    match tok with
    | Parser.EOF -> ()
    | _ -> go ()
  in
  try go ()
  with
  | Error.Error (loc, msg) ->
     Format.printf "%a error: %s\n" Location.pp_location loc msg

let%expect_test _ =
  (* white spaces and comments *)
  scan_string "";
  [%expect{| :1.0-1.0 Parser.EOF |}];

  scan_string "   \t\t \n     \n  ";
  [%expect{| :3.2-3.2 Parser.EOF |}];

  scan_string "# a line comment";
  [%expect{| :1.16-1.16 Parser.EOF |}];

  scan_string "{# a block comment #}";
  [%expect{| :1.21-1.21 Parser.EOF |}];

  scan_string "{# a {# nested {# block #} comment #} here #}";
  [%expect{| :1.45-1.45 Parser.EOF |}];

  scan_string "{# an unterminated block comment";
  [%expect{| :1.0-1.32 error: unterminated comment |}];

  scan_string "{# an unterminated {# nested block comment #} here";
  [%expect{| :1.0-1.50 error: unterminated comment |}];

  (* logic literals *)
  scan_string "true false";
  [%expect{|
    :1.0-1.4 (Parser.LITBOOL true)
    :1.5-1.10 (Parser.LITBOOL false)
    :1.10-1.10 Parser.EOF |}];

  (* integer literals *)
  scan_string "0 139015 007 -4324 +2019";
  [%expect{|
           :1.0-1.1 (Parser.LITINT 0)
           :1.2-1.8 (Parser.LITINT 139015)
           :1.9-1.12 (Parser.LITINT 7)
           :1.13-1.14 Parser.MINUS
           :1.14-1.18 (Parser.LITINT 4324)
           :1.19-1.20 Parser.PLUS
           :1.20-1.24 (Parser.LITINT 2019)
           :1.24-1.24 Parser.EOF |}];
