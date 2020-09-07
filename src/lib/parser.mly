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
%token                 UMINUS

%right                 OR
%right                 AND
%left                  EQ NE GT GE LT LE
%left                  PLUS MINUS
%left                  TIMES DIV MOD
%right                 POW
%nonassoc              UMINUS

%start <Absyn.lexp> program

%%

program:
| e=exp EOF                               {e}

exp:
| x=LITBOOL                               {$loc, BoolExp x}
| x=LITINT                                {$loc, IntExp x}
| x=LITREAL                               {$loc, RealExp x}
| MINUS e=exp             %prec UMINUS    {$loc, NegativeExp e}
| l=exp PLUS r=exp                        {$loc, BinaryExp (l, Plus, r)}
| l=exp MINUS r=exp                       {$loc, BinaryExp (l, Minus, r)}
| l=exp TIMES r=exp                       {$loc, BinaryExp (l, Times, r)}
| l=exp DIV r=exp                         {$loc, BinaryExp (l, Div, r)}
| l=exp MOD r=exp                         {$loc, BinaryExp (l, Mod, r)}
| l=exp POW r=exp                         {$loc, BinaryExp (l, Power, r)}
| l=exp EQ r=exp                          {$loc, BinaryExp (l, Equal, r)}
| l=exp NE r=exp                          {$loc, BinaryExp (l, NotEqual, r)}
| l=exp GT r=exp                          {$loc, BinaryExp (l, GreaterThan, r)}
| l=exp GE r=exp                          {$loc, BinaryExp (l, GreaterEqual, r)}
| l=exp LT r=exp                          {$loc, BinaryExp (l, LowerThan, r)}
| l=exp LE r=exp                          {$loc, BinaryExp (l, LowerEqual, r)}
| l=exp AND r=exp                         {$loc, BinaryExp (l, And, r)}
| l=exp OR r=exp                          {$loc, BinaryExp (l, Or, r)}
| WHILE t=exp DO b=exp                    {$loc, WhileExp (t, b)}
| BREAK                                   {$loc, BreakExp}
| x=var                                   {$loc, VarExp x}
| LET x=list(dec) IN e=exp                {$loc, LetExp (x, e)}

var:
| x=ID                                    {$loc, SimpleVar x }

dec:
| VAR x=ID  t=optionaltype EQ e=exp       {$loc, VarDec (x, t, e) }

optionaltype:
| ot=option(COLON t=ID {t})               {ot}

(* decvar:
| x=svar EQ e=exp                         { DecVar (x, None, e) }
| x=svar COLON t=option(ID) EQ e=exp      { DecVar (x, t, e) } *)
