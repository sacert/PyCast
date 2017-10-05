%{
#include "expr-inherit.tab.h"
#include <stdlib.h>
%}

%%
[0-9]+    { yylval.intval = atoi(yytext); return T_INTCONSTANT; }
[ \t\n]   ;
.         return yytext[0];
%%
