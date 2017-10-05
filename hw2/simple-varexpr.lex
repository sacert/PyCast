%{
#include "simple-varexpr.tab.h"
#include <math.h>
%}

%%
[0-9]+    { yylval.rvalue = atoi(yytext); return NUMBER; } /* convert NUMBER token value to integer */
[ \t\n]   ;  /* ignore whitespace */
[a-z]     { yylval.lvalue = yytext[0] - 'a'; return NAME; } /* convert NAME token into index */
.         return yytext[0];
%%
