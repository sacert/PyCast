%{
#include <stdio.h>
#define SINGLE  256
#define MULTI   257
%}


%%
\"(.|\n)*\"	                      {return -1;}
\/\/.*		                        {return SINGLE; }
\/\*[^*]*\*+(?:[^*/][^*]*\*+)*\/  {return MULTI;}
%%

int main () {
  int token, i;

  while ((token = yylex())) {

    switch (token) {
      case SINGLE :
      	for(i = 0; i < (int) yyleng; i++)
      		printf(" ");
      	break;
      case MULTI :
      	for(i = 0; i< (int) yyleng; i++) {
      		if(yytext[i] == '\n')
              printf("\n");
      		else
              printf(" ");
      	}
      	break;
      default: printf("%s", yytext);
    }
  }
  exit(0);
}
