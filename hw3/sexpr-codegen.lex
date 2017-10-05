%{
#include "exprdefs.h"
#include "sexpr-codegen.tab.h"
#include <stdlib.h>
%}
%%
[0-9]+   { yylval.number = atoi(yytext); return NUMBER; }
[ \t\n]  ;
.        return yytext[0];
%%
