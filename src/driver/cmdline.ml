(* handling command line arguments: implementation *)

let input_filename = ref ""

let input_channel = ref stdin

let get_input_filename () =
  !input_filename

let get_input_channel () =
  !input_channel

let set_input filename =
  try
    input_filename := filename;
    input_channel := open_in filename
  with Sys_error err ->
    raise (Arg.Bad ("Cannot open '" ^ filename ^ "': " ^ err))

let usage_msg =
  "Usage: " ^ Sys.argv.(0) ^ " [OPTION]... FILE\n"

let rec usage () =
  Arg.usage options usage_msg;
  exit 0

and options =
  [ "-help",   Arg.Unit usage, "\tDisplay an usage message"
  ; "--help",  Arg.Unit usage, "\tDisplay an usage message"
  ]

let parse () =
  Arg.parse options set_input usage_msg
