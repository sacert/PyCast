%{
#include <stdio.h>
#define NUMBER     256
#define IDENTIFIER 257
%}

/* regexp definitions */
num [0-9]+

%%

{num}           { return NUMBER; }
[a-zA-Z][a-zA-Z0-9]*    { return IDENTIFIER; }
\n              /* do nothing */
.		{ return -1; }

%%

int main () {
  int token;
  while ((token = yylex())) {
    switch (token) {
      case NUMBER: printf("NUMBER: %s, LENGTH:%d\n", yytext, (int)yyleng); break;
      case IDENTIFIER: printf("IDENTIFIER: %s, LENGTH:%d\n", yytext, (int)yyleng); break;
      default: printf("Error: %s not recognized\n", yytext);
    }
  }
  exit(0);
}
