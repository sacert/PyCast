
%{
/*
flex -o simplereject.c simplereject.lex 
gcc -o simplereject simplereject.c -lfl

test using:
echo "abcd" | ./simplereject
*/

#include <stdio.h>

%}

%%

..		{ printf("[%c %c]\n", yytext[0], yytext[1]); REJECT; }
\n		;
.		;
%%

int main () {
  yylex();
}

