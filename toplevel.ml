(*===----------------------------------------------------------------------===
 * Top-Level parsing and JIT Driver
 *===----------------------------------------------------------------------===*)

open Llvm

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

  | Ast.Definition e ->
    print_endline "parsed a function definition:";
    dump_value (Codegen.codegen_func e);
    prompt ()
  | Ast.Extern e ->
    print_endline "parsed an extern:";
    dump_value (Codegen.codegen_proto e);
    prompt ()
  | Ast.Expression e ->
    print_endline "parsed a top-level expr:";
    dump_value (Codegen.codegen_func e);
    prompt ()

  with
  | Parsing.Parse_error ->
    (* Discard buffer contents for error recovery. *)
    Lexing.flush_input lexbuf; prompt ()
