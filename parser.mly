%{
  open Ast
  open Lexing
  let parse_error s =
    begin
      try
        let start_pos = Parsing.symbol_start_pos ()
        and end_pos = Parsing.symbol_end_pos () in
        Printf.printf "File \"%s\", line %d, characters %d-%d: \n"
          start_pos.pos_fname
          start_pos.pos_lnum
          (start_pos.pos_cnum - start_pos.pos_bol)
          (end_pos.pos_cnum - start_pos.pos_bol)
      with Invalid_argument(_) -> ()
    end;
    Printf.printf "Syntax error: %s\n" s;
    raise Parsing.Parse_error
%}
/*===----------------------------------------------------------------------===
 * Lexer Tokens
 *===----------------------------------------------------------------------===*/

/* The lexer returns these 'UNKNOWN' if it is an unknown character, otherwise
 * one of these others for known things. */

/* commands */
%token DEF EXTERN
/* primary */
%token <string> IDENT
%token <float> NUMBER
/* parens */
%token LPAREN RPAREN
/* punctuation */
%token COMMA SEMICOLON
/* end of stream */
%token EOS
/* unknown token */
%token UNKNOWN
/* binary operators */
%token LESS_THAN PLUS MINUS TIMES

/*===---------------------------------------------------------------------===
 * Parser
 *===---------------------------------------------------------------------===*/

%left LESS_THAN
%left PLUS MINUS
%left TIMES

%start toplevel
%type <Ast.toplevel> toplevel
%%

expr:
  /* numberexpr ::= number */
  | NUMBER                           { Number $1 }

  /* parenexpr ::= '(' expression ')' */
  | LPAREN expr RPAREN               { $2 }
  | LPAREN expr                      { parse_error "expected ')'" }

  /* identifierexpr
   *   ::= identifier
   *   ::= identifier '(' argumentexpr ')' */
  | IDENT LPAREN argumentexpr RPAREN { Call($1, Array.of_list $3) }
  | IDENT LPAREN RPAREN              { Call($1, Array.of_list []) }
  | IDENT LPAREN argumentexpr        { parse_error "expected ')'" }
  | IDENT                            { Variable $1 }

  /* binopexpr ::= expr BINOP expr */
  | expr LESS_THAN expr              { Binary('<', $1, $3) }
  | expr PLUS expr                   { Binary('+', $1, $3) }
  | expr MINUS expr                  { Binary('-', $1, $3) }
  | expr TIMES expr                  { Binary('*', $1, $3) }

  | UNKNOWN                          { parse_error "unknown token when expecting an expression." }
;
argumentexpr:
  | expr COMMA argumentexpr          { $1 :: $3 }
  | expr                             { [$1] }
;

/* prototype
 *   ::= id '(' id* ')' */
prototype:
  | IDENT LPAREN idents RPAREN       { Prototype($1, Array.of_list $3) }
  | IDENT LPAREN idents              { parse_error "expected ')' in prototype" }
  | IDENT                            { parse_error "expected '(' in prototype" }
;
idents:
  | IDENT idents                     { $1 :: $2 }
  |                                  { [] }
;

/*  external ::= 'extern' prototype */
extern:
  | EXTERN prototype                 { $2 }
;

/* definition ::= 'def' prototype expression */
definition:
  | DEF prototype expr               { Function($2, $3) }
;

/* toplevel ::= expression |  */
toplevel:
  | statement terminator             { $1 }
  | terminator                       { $1 }
;
statement:
  | expr                             { Expression(Function(Prototype("", [||]), $1)) }
  | extern                           { Extern $1 }
  | definition                       { Definition $1 }
;
terminator:
  | SEMICOLON                        { Sep }
  | EOS                              { End }
;
