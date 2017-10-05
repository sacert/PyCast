%{
#include <stdio.h>

int exprval = 0;
%}

%union {
  int intval;
}

%token <intval> T_INTCONSTANT
%type <intval> expr term top

%start top
%%

top: expr { printf("%d\n", $1); }

expr: { printf("+"); } expr '+' term
   | { printf("*"); } expr '*' term
   | term
   ;

term: T_INTCONSTANT { printf("%d", $1); }

%%

