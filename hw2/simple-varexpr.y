%{
#include <stdio.h>
#include <stdbool.h>
int symtbl[26];
bool issym[26];
%}

%union {
  int rvalue; /* value of evaluated expression */
  int lvalue; /* index into symtbl for variable name */
}

%token <rvalue> NUMBER
%token <lvalue> NAME 

%type <rvalue> expression

%%
statement: NAME '=' expression { symtbl[$1] = $3; issym[$1] = true; }
         | expression  { printf("%d\n", $1); }
         ;

expression: expression '+' NUMBER { $$ = $1 + $3; }
         | expression '-' NUMBER { $$ = $1 - $3; }
         | NUMBER { $$ = $1; }
         ;
%%

