{
  module L = Lexing

  type token = [%import: Parser.token] [@@deriving show]

  let set_filename lexbuf fname =
    lexbuf.L.lex_curr_p <-
      { lexbuf.L.lex_curr_p with L.pos_fname = fname }

  let illegal_character loc char =
    Error.error loc "illegal character '%c'" char

  let comment_begin = ref L.dummy_pos
}

let spaces = [' ' '\t']+
let digit = ['0'-'9']
let integer = digit+
let exponent = ['e' 'E'] ['+' '-']? integer
let real = integer ('.' integer exponent? | exponent)
let id = ['a'-'z''A'-'Z']['0'-'9''a'-'z''A'-'Z''_']*

rule token = parse
  | spaces            { token lexbuf }
  | '\n'              { L.new_line lexbuf; token lexbuf }
  | real as lxm       { LITREAL (float_of_string lxm) }
  | integer as lxm    { LITINT (int_of_string lxm) }
  | "true"            { LITBOOL true }
  | "false"           { LITBOOL false }
  | "{#"              { comment_begin := L.lexeme_start_p lexbuf; read_comment 0 lexbuf }
  | "+"               { PLUS }
  | "-"               { MINUS }
  | "*"               { TIMES }
  | "/"               { DIV }
  | "%"               { MOD }
  | "^"               { POW }
  | "="               { EQ }
  | "<>"              { NE }
  | ">"               { GT }
  | ">="              { GE }
  | "<"               { LT }
  | "<="              { LE }
  | "&&"              { AND }
  | "||"              { OR }
  | ":="              { ASSIGN }
  | "while"           { WHILE }
  | "do"              { DO }
  | "var"             { VAR }
  | "if"              { IF }
  | "then"            { THEN }
  | "else"            { ELSE }
  | "break"           { BREAK }
  | "let"             { LET }
  | "in"              { IN }
  | "end"             { END }
  | id as lxm         { ID (Symbol.symbol lxm) }
  | eof               { EOF }
  | _                 { illegal_character (Location.curr_loc lexbuf) (L.lexeme_char lexbuf 0) }

and read_comment nested_count = parse
  | "{#"  { read_comment (nested_count+1) lexbuf }
  | "#}"  { if nested_count = 0 then
              token lexbuf
            else
              read_comment (nested_count-1) lexbuf
          }
  | '\n'  { L.new_line lexbuf; read_comment nested_count lexbuf }
  | eof   { Error.error (!comment_begin, L.lexeme_end_p lexbuf) "unterminated comment" }
  | _     { read_comment nested_count lexbuf }
