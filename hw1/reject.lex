
%{
int numpat1, numpat2;
%}

%%
a+     { numpat1++; REJECT; }
a*b?   { numpat2++; REJECT; }
.|\n   /* do nothing */
%%

int main () {
  yylex();
  printf("pattern a+: %d -- pattern a*b?: %d\n", numpat1, numpat2);
  exit(0);
}

