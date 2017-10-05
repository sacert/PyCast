%{
/* example that illustrates using C++ code and flex/bison */

/* note that this particular example does not use the C++ flex
interface as described in the bison manual */

#include "usingcpp-defs.h"
#include <cstring>
#include <string>
#include <iostream>

using namespace std;

%}

/* in the definition of %union you can only have scalar types like
int, double or a pointer type, e.g. you cannot have 'string tval'
as a valid type for tokens or non-terminals */

%union {
  char *sval;
  string *tval; 
}

%token <sval> NAME /* define return type for tokens from lexical analyzer */
%type <tval> tree children /* define return type for non-terminals in grammar */

%%

start: tree
  { cout << *$1 << endl; }

tree: '(' NAME children ')'
  { string *tval = new string; *tval += $2; *tval += *$3; delete $2; delete $3; $$ = tval; }
    | NAME
  { string *tval = new string; *tval += $1; delete $1; $$ = tval; }
    ;

children: tree children
  { string *tval = new string; *tval += *$1; *tval += *$2; delete $1; delete $2; $$ = tval; }
    | tree
  { $$ = $1; }
    ;

%%

