// parser.mly

%{

%}

%token                 EOF
%token <int>           LITINT
%token <bool>          LITBOOL
%token <float>         LITREAL

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
%%
