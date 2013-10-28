(*===----------------------------------------------------------------------===
 * Top-Level parsing and JIT Driver
 *===----------------------------------------------------------------------===*)

(* top ::= definition | external | expression | ';' *)
let rec main_loop lexbuf =
  let prompt = fun () ->
    print_string "ready> "; flush stdout;
    main_loop lexbuf in
  try match Parser.toplevel Lexer.token lexbuf with
  | Ast.End -> ()

  (* ignore top-level semicolons. *)
  | Ast.Sep ->
    Lexing.flush_input lexbuf;
    main_loop lexbuf

  | Ast.Func _ ->
    print_endline "parsed a function definition."; prompt ()
  | Ast.Proto _ ->
    print_endline "parsed an extern."; prompt ()
  | Ast.Expr _ ->
    print_endline "parsed a top-level expr"; prompt ()

  with e ->
    (* Discard buffer contents for error recovery. *)
    Lexing.flush_input lexbuf;
    print_endline (Printexc.to_string e);
    prompt ()
