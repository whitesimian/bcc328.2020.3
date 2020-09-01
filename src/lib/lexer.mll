{
  module L = Lexing

  type token = [%import: Parser.token] [@@deriving show]

  let set_filename lexbuf fname =
    lexbuf.L.lex_curr_p <-
      { lexbuf.L.lex_curr_p with L.pos_fname = fname }

  let illegal_character loc char =
    Error.error loc "illegal character '%c'" char
}

let spaces = [' ' '\t']+
let digit = ['0'-'9']

rule token = parse
  | spaces            { token lexbuf }
  | '\n'              { L.new_line lexbuf; token lexbuf }
  | digit+ as lxm     { LITINT (int_of_string lxm) }
  | "true"            { LITBOOL true }
  | "false"           { LITBOOL false }
  | "{#"              { read_comment 0 lexbuf}
  | eof               { EOF }
  | _                 { illegal_character (Location.curr_loc lexbuf) (L.lexeme_char lexbuf 0) }

and read_comment nested_count = parse
  | "{#"  { read_comment (nested_count+1) lexbuf }
  | "#}"  { if nested_count = 0 then
              token lexbuf
            else
              read_comment (nested_count-1) lexbuf
          }
  | eof   { Error.error (Location.curr_loc lexbuf) "unterminated comment" }
  | _     { read_comment nested_count lexbuf }
