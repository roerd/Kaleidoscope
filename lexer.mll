(*===----------------------------------------------------------------------===
 * Lexer
 *===----------------------------------------------------------------------===*)
{
  open Parser
}
let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
rule token = parse
  (* Skip any whitespace. *)
  | [' ' '\t']                            { token lexbuf }
  | ['\n' '\r' ]
      { Lexing.new_line lexbuf; token lexbuf }

  | "def"                                 { DEF }
  | "extern"                              { EXTERN }

  (* identifier: [a-zA-Z][a-zA-Z0-9]* *)
  | ( letter ( letter | digit )* ) as lxm { IDENT(lxm) }

  (* number: [0-9.]+ *)
  | ( digit ( digit | '.' )* ) as lxm     { NUMBER(float_of_string lxm) }

  (* Comment until end of line. *)
  | '#' [^ '\n']*                         { token lexbuf }

  (* Parens *)
  | '('                                   { LPAREN }
  | ')'                                   { RPAREN }

  (* Punctuation *)
  | ','                                   { COMMA }
  | ';'                                   { SEMICOLON }

  (* binary operators *)
  | '<'                                   { LESS_THAN }
  | '+'                                   { PLUS }
  | '-'                                   { MINUS }
  | '*'                                   { TIMES }

  (* end of stream. *)
  | eof                                   { EOS }

  | _                                     { UNKNOWN }
