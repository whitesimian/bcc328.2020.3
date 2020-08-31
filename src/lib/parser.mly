// parser.mly

%{

%}

%token                 EOF
%token <int>           LITINT
%token <bool>          LITBOOL
%token PLUS
%token MINUS
%token TIMES
%token DIV
%token LPAREN
%token RPAREN

%%
