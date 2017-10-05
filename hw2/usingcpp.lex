%{
/* example that illustrates using C++ code and flex/bison */
using namespace std;
#include "usingcpp-defs.h"
#include "usingcpp.tab.h"
#include <cstring>
%}

%%
[a-z]                  { yylval.sval = strdup(yytext); return NAME; }
[ \t\n]                ;
.                      return yytext[0];
%%

