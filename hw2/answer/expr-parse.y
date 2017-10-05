%{

#include <string>
#include <cstdarg>

using namespace std;
extern "C"
{
  int yylex(void);
  int yywrap(void);
  int yyparse(void);
  int yyerror(const char *);
}

#include <sstream>
#include <iostream>

string *makeTree(const char *root, int i,...){
    string *tree = new string;
    ostringstream oss;
    va_list vaL;
    va_start(vaL, i);
    oss << "(" << root;
    for(string *va = va_arg(vaL, string *); i; va = va_arg(vaL, string *), --i){
      oss << " " << *va;
    }
    oss << ")";
    *tree = string(oss.str());
    return tree;
  }
%}

%union {
   char *sval;   // token
   string *tval; // type
}

%token <sval> PLUS "+"
%token <sval> TIMES "*"
%token <sval> LPAREN "\\("
%token <sval> RPAREN "\\)"
%token <sval> ID
%type <tval> start
%type <tval> e
%type <tval> t
%type <tval> f

%%

start	:	e	{cout << *$$ << endl;};
e	:	e PLUS t { $$ = makeTree("e", 3, $1, makeTree("PLUS", 1, new string("+")), $3);}
	|	t	 { $$ = makeTree("e", 1, $1);};
t	:	t TIMES f { $$ = makeTree("t", 3, $1, makeTree("TIMES", 1, new string("*")), $3);}
	|	f	  { $$ = makeTree("t", 1, $1);};
f	:	LPAREN e RPAREN	{ $$ = makeTree("f", 3, makeTree("LPAREN", 1, new string("\\(")), $2, makeTree("RPAREN", 1, new string("\\)")));}
	|	ID		{ $$ = makeTree("f", 1, makeTree("ID", 1, new string (yylval.sval)));};

%%


int main() {
	return yyparse();
}
