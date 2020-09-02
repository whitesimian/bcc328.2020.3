// parser.mly

%{
  open Absyn
%}

%token                 EOF
%token <bool>          LITBOOL
%token <int>           LITINT
%token <float>         LITREAL
%token <Symbol.symbol> ID

%token                 PLUS
%token                 MINUS
%token                 TIMES
%token                 DIV
%token                 MOD
%token                 POW
%token                 EQ
%token                 NE
%token                 GT
%token                 GE
%token                 LT
%token                 LE
%token                 AND
%token                 OR
%token                 ASSIGN
%token                 LPAREN
%token                 RPAREN
%token                 COMMA
%token                 SEMI
%token                 COLON
%token                 BREAK
%token                 DO
%token                 ELSE
%token                 END
%token                 IF
%token                 IN
%token                 LET
%token                 THEN
%token                 VAR
%token                 WHILE

%start <Absyn.exp> program

%%

program:
| e=exp EOF            {e}

exp:
| x=LITBOOL            {BoolExp x}
| x=LITINT             {IntExp x}
| x=LITREAL            {RealExp x}
| WHILE t=exp DO b=exp {WhileExp (t, b)}
| BREAK                {BreakExp}
