%{
#include <stdio.h>
int currLine = 1;
int currPosition = 0;
%}

%%
"&&"  {printf("T_AND %s\n", yytext); currPosition += (int) yyleng;}
"="   {printf("T_ASSIGN %s\n", yytext); currPosition += (int) yyleng;}
"bool"  {printf("T_BOOLTYPE %s\n", yytext); currPosition += (int) yyleng;}
"break" {printf("T_BREAK %s\n", yytext); currPosition += (int) yyleng;}
\'(\\a|\\b|\\t|\\n|\\v|\\f|\\r|\\\\|\\\'|\\\"|[^\\])\' {printf("T_CHARCONSTANT %s\n", yytext); currPosition += 3;} //check
\'[^\'][^\']+ {fprintf(stderr, "Error: char constant length is greater than one\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition + 1); exit(1);}
\'\' {fprintf(stderr, "Error: char constant has zero width\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition + 1); exit(1);}
\' {fprintf(stderr, "Error: unterminated char constant\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition + 1); exit(1);}
"class" {printf("T_CLASS %s\n", yytext); currPosition += (int) yyleng;}
\/\/.*\s*\n {printf("T_COMMENT ");
             for(int i=0;i<(int) yyleng;i++) {
                if(yytext[i] == '\n') {
                    printf("\\n\n");
                    currLine++;
                    currPosition = 0;
                }else {
                    printf("%c", yytext[i]);
                    currPosition++;
                }
             }}  // go over
"," {printf("T_COMMA %s\n", yytext); currPosition += (int) yyleng;}
"continue" {printf("T_CONTINUE %s\n", yytext); currPosition += (int) yyleng;}
"/" {printf("T_DIV %s\n", yytext); currPosition += (int) yyleng;}
"." {printf("T_DOT %s\n", yytext); currPosition += (int) yyleng;}
"else" {printf("T_ELSE %s\n", yytext); currPosition += (int) yyleng;}
"==" {printf("T_EQ %s\n", yytext); currPosition += (int) yyleng;}
"extends" {printf("T_EXTENDS %s\n", yytext); currPosition += (int) yyleng;}
"extern" {printf("T_EXTERN %s\n", yytext); currPosition += (int) yyleng;}
"false" {printf("T_FALSE %s\n", yytext); currPosition += (int) yyleng;}
"for" {printf("T_FOR %s\n", yytext); currPosition += (int) yyleng;}
">=" {printf("T_GEQ %s\n", yytext); currPosition += (int) yyleng;}
">" {printf("T_GT %s\n", yytext); currPosition += (int) yyleng;}
"if" {printf("T_IF %s\n", yytext); currPosition += (int) yyleng;}
[0][xX][1-9a-fA-F][0-9a-fA-F]+ {printf("T_INTCONSTANT %s\n", yytext); currPosition += (int) yyleng;} //more than one digit hex
[0][xX][0-9a-fA-F] {printf("T_INTCONSTANT %s\n", yytext); currPosition += (int) yyleng;} //one digit hex
[1-9][0-9]+ {printf("T_INTCONSTANT %s\n", yytext); currPosition += (int) yyleng;} //more than one digit decimal
[0-9] {printf("T_INTCONSTANT %s\n", yytext); currPosition += (int) yyleng;} //one digit decimal
"int" {printf("T_INTTYPE %s\n", yytext); currPosition += (int) yyleng;}
"{" {printf("T_LCB %s\n", yytext); currPosition += (int) yyleng;}
"<<" {printf("T_LEFTSHIFT %s\n", yytext); currPosition += (int) yyleng;}
"<=" {printf("T_LEQ %s\n", yytext); currPosition += (int) yyleng;}
"(" {printf("T_LPAREN %s\n", yytext); currPosition += (int) yyleng;}
"[" {printf("T_LSB %s\n", yytext); currPosition += (int) yyleng;}
"<" {printf("T_LT %s\n", yytext); currPosition += (int) yyleng;}
"-" {printf("T_MINUS %s\n", yytext); currPosition += (int) yyleng;}
"%" {printf("T_MOD %s\n", yytext); currPosition += (int) yyleng;}
"*" {printf("T_MULT %s\n", yytext); currPosition += (int) yyleng;}
"!=" {printf("T_NEQ %s\n", yytext); currPosition += (int) yyleng;}
"new" {printf("T_NEW %s\n", yytext); currPosition += (int) yyleng;}
"!" {printf("T_NOT %s\n", yytext); currPosition += (int) yyleng;}
"null" {printf("T_NULL %s\n", yytext); currPosition += (int) yyleng;}
"||" {printf("T_OR %s\n", yytext); currPosition += (int) yyleng;}
"+" {printf("T_PLUS %s\n", yytext); currPosition += (int) yyleng;}
"}" {printf("T_RCB %s\n", yytext); currPosition += (int) yyleng;}
"return" {printf("T_RETURN %s\n", yytext); currPosition += (int) yyleng;}
">>" {printf("T_RIGHTSHIFT %s\n", yytext); currPosition += (int) yyleng;}
")" {printf("T_RPAREN %s\n", yytext); currPosition += (int) yyleng;}
"]" {printf("T_RSB %s\n", yytext); currPosition += (int) yyleng;}
";" {printf("T_SEMICOLON %s\n", yytext); currPosition += (int) yyleng;}
"string" {printf("T_STRINGTYPE %s\n", yytext); currPosition += (int) yyleng;}
\"((\\a|\\b|\\t|\\n|\\v|\\f|\\r|\\\\|\\\'|\\\")|[^\\\"\n])*\"	{printf("T_STRINGCONSTANT %s\n", yytext); currPosition += (int) yyleng;}
\"[^\\]*\\[^abtnvfr\\\'\"] {fprintf(stderr, "Error: unknown escape sequence in string constant\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition + 1); exit(1);}
\"([^\\\"\n]|(\\\"))*\n {fprintf(stderr, "Error: newline in string constant\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition + 1); exit(1);}
\" {fprintf(stderr, "Error: string constant is missing closing delimiter\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition+1); exit(1);}
"true" {printf("T_TRUE %s\n", yytext); currPosition += (int) yyleng;}
"void" {printf("T_VOID %s\n", yytext); currPosition += (int) yyleng;}
"while" {printf("T_WHILE %s\n", yytext); currPosition += (int) yyleng;}
[a-zA-Z_][a-zA-Z0-9_]* {printf("T_ID %s\n", yytext); currPosition += (int) yyleng;}
[\n\r\t\v\f ]+ {int i; printf("T_WHITESPACE ");
                for(i = 0; i< (int) yyleng; i++) {
                      if(yytext[i] == '\n') {
                            printf("\\n");
                             currPosition = 0;
                             currLine++;
                      } else {
                            printf("%c", yytext[i]);
                            currPosition++;
                      }
                } printf("\n");}
. {fprintf(stderr, "Error: unexpected character in input\n"); fprintf(stderr, "Lexical error: line %d, position %d\n", currLine, currPosition+1); exit(1);}
%%

int main() {
  int token;
  if(token == yylex()) {
    switch(token) {
      default: printf("%s", yytext);
    }
  }
  exit(0);
}
