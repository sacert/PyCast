%{
#include <stdio.h>

int exprval = 0;

int yylex(void);
int yyerror(char *); 

%}

%union {
  int intval;
}

%token <intval> T_INTCONSTANT
%type <intval> expr term rest top

%start top
%%

top: expr { printf("%d\n", $1); }

expr: term { $<intval>$ = $1; } rest { $$ = $3; }

rest: '+' term { $<intval>$ = $<intval>0 + $2; } rest {$$ = $4; }
   | /* empty */ { $<intval>$ = $<intval>0; }
   ;

term: T_INTCONSTANT { $$ = $1; }

%%

