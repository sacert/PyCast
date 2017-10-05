%{

#include <string>
#include <stdlib.h>

using namespace std;
extern "C"
{
  int yylex(void);
}

#include "expr-parse.tab.h"
%}


%%
\+	                         { return PLUS; }
\*	                         { return TIMES; }
\(	                         { return LPAREN; }
\)	                         { return RPAREN; }
[a-zA-Z_][0-9a-zA-Z_]*       { yylval.sval = strdup(yytext); return ID; }
[ \t\n]                      { /* do nothing */ }
.	                           { return fprintf (stderr, "syntax error\n"); return 0;}
%%
