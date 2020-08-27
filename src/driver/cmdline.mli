(* handling command line arguments: interface *)

val get_input_filename : unit -> string
val get_input_channel : unit -> in_channel

val parse : unit -> unit
