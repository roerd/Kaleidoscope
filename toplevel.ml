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

  | Ast.Definition _ ->
    print_endline "parsed a function definition."; prompt ()
  | Ast.Extern _ ->
    print_endline "parsed an extern."; prompt ()
  | Ast.Expression _ ->
    print_endline "parsed a top-level expr"; prompt ()

  with
  | Failure(s) ->
    (* Discard buffer contents for error recovery. *)
    Lexing.flush_input lexbuf;
    print_string "Syntax error: ";
    print_endline s;
    prompt ()
