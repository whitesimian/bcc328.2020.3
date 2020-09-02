// parser.mly

%{
  open Absyn
%}

%token                 EOF
%token <int>           LITINT
%token <bool>          LITBOOL
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
%token                 WHILE
%token                 DO
%token                 VAR IF THEN ELSE BREAK LET IN END    

%start <Absyn.exp> program

%%

program:
| e=exp EOF            {e}

exp:
| x=LITINT             {IntExp x}
| x=LITBOOL            {BoolExp x}
| WHILE t=exp DO b=exp {WhileExp (t, b)}
