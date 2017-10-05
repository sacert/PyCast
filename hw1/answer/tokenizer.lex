%{
#include <stdio.h>
#define T_A 256
#define T_B 257
#define T_C 258
#define T_ERROR 259
%}


%%
abb     { return T_B; }
a*b+    { return T_C; }
a       { return T_A; }
.       { return T_ERROR; }
%%

int main () {
    int token;
    while ((token = yylex())) {
        switch (token) {
            case T_A: printf("T_A %s", yytext); break;
            case T_B: printf("T_B %s\n", yytext); break;
            case T_C: printf("T_C %s\n", yytext); break;
            case T_ERROR: printf("ERROR %s\n", yytext); break;
            default: ;
        }
    }
    exit(0);
}
