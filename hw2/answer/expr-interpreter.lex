%{
#include <stdlib.h>
#include "expr-interpreter.tab.h"
int yylex();
void yyerror(char const *);
%}

digit [0-9]
integer {digit}+
real ({digit}+[.]{digit}+)

%%

exp         { return EXP; }
log         { return LOG; }
sqrt 	     { return SQRT; }
    /* variable */
[a-z]       { yylval.iValue = yytext[0]; return NAME; }

    /* number */
{real}      { yylval.dValue = atof(yytext); return DOUBLE; }
{integer}   { yylval.iValue = atof(yytext); return NUMBER; }

    /* ignore whitespace */
[ \t]  /* ignore whitespace */

    /* symbol */
[-+=*/\n\(\)]  return *yytext;

    /* anything else is an error */
.   return yytext[0];
%%
