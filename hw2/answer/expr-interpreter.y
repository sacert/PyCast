%{
#include <stdio.h>
#include <stdbool.h>
#include <math.h>
double sym[26];
int yylex();
void yyerror(char const *);
%}

%union {
    int iValue;
    double dValue;
}
%token EXP LOG SQRT
%token <dValue> DOUBLE
%token <iValue> NAME NUMBER
%type <dValue> expression

%%
input: /* empty */
     | input statement '\n'
     | input '\n'
     ;

statement: NAME '=' expression { sym[$1] = $3; }
   | expression { printf("%f\n", $1); }
   ;

expression: EXP '(' expression ')' { $$ = exp($3); }
   | SQRT '(' expression ')' { $$ = sqrt($3); }
   | LOG '(' expression ')' { $$ = log($3); }
   | expression '+' NUMBER { $$ = $1 + $3; }
   | expression '-' NUMBER { $$ = $1 - $3; }
   | expression '+' DOUBLE { $$ = $1 + $3; }
   | expression '-' DOUBLE { $$ = $1 - $3; }
   | expression '+' NAME  { $$ = sym[$3] + $1; }
   | expression '-' NAME { $$ = sym[$3] - $1; }
   | NUMBER { $$ = $1; }
   | NAME { $$ = sym[$1]; }
   | DOUBLE { $$ = $1; }
   ;
%%
