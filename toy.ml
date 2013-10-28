(*===----------------------------------------------------------------------===
 * Main driver code.
 *===----------------------------------------------------------------------===*)

let main () =
  (* Prime the first token. *)
  print_string "ready> "; flush stdout;
  let lexbuf = Lexing.from_channel stdin in

  (* Run the main "interpreter loop" now. *)
  Toplevel.main_loop lexbuf;
;;

main ()
