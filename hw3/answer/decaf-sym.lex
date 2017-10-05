%{
#include "decaf-sym.h"
#include "decaf-sym.tab.h"
#include <cstring>
#include <string>
#include <sstream>
#include <iostream>

using namespace std;

int lineno = 1;
int tokenpos = 1;

string *preterm(const char* token, const char* lexeme) {
  string *tree = new string;
  ostringstream s;
  s << "(" << token << " " << lexeme << ")";
  *tree = string(s.str());
  return tree;
}

string remove_newlines (string s) {
  string newstring;
  for (string::iterator i = s.begin(); i != s.end(); i++) {
    switch(*i) {
    case '\n':
      lineno += 1; tokenpos = 0;
      newstring.push_back('\\');
      newstring.push_back('n');
      break;
    case '(':
      newstring.push_back('\\');
      newstring.push_back('(');
      break;
    case ')':
      newstring.push_back('\\');
      newstring.push_back(')');
      break;
    default:
      newstring.push_back(*i);
    }
  }
  return newstring;
}

string *process_token(const char *str) {
  tokenpos += yyleng;
  string lexeme(yytext);
  lexeme = remove_newlines(lexeme);
  return preterm(str, lexeme.c_str());
}

void process_ws() {
  tokenpos += yyleng;
  string lexeme(yytext);
  lexeme = remove_newlines(lexeme);
}

string *process_string (const char *s) {
  string *ns = new string("");
  size_t len = strlen(s);
  // remove the double quotes, use s[1..len-1]
  for (int i = 1; i < len-1; i++) {
    if (s[i] == '\\') {
      i++;
      switch(s[i]) {
      case 't': ns->push_back('\t'); break;
      case 'v': ns->push_back('\v'); break;
      case 'r': ns->push_back('\r'); break;
      case 'n': ns->push_back('\n'); break;
      case 'a': ns->push_back('\a'); break;
      case 'f': ns->push_back('\f'); break;
      case 'b': ns->push_back('\b'); break;
      case '\\': ns->push_back('\\'); break;
      case '\'': ns->push_back('\''); break;
      case '\"': ns->push_back('\"'); break;
      default: throw runtime_error("unknown char escape\n");  
      }
    } else {
      ns->push_back(s[i]);
    }
  }
  return ns;
}

int get_charconstant(const char *s) {
  if (s[1] == '\\') { // backslashed char
    switch(s[2]) {
    case 't': return (int)'\t';
    case 'v': return (int)'\v';
    case 'r': return (int)'\r';
    case 'n': return (int)'\n';
    case 'a': return (int)'\a';
    case 'f': return (int)'\f';
    case 'b': return (int)'\b';
    case '\\': return (int)'\\';
    case '\'': return (int)'\'';
    default: throw runtime_error("unknown char constant\n");
    }
  } else {
    return (int)s[1];
  }
}

int get_intconstant(const char *s) {
  if ((s[0] == '0') && (s[1] == 'x')) {
    int x;
    sscanf(s, "%x", &x);
    return x;
  } else {
    return atoi(s);
  }
}

%}

chars    [ !\"#\$%&\(\)\*\+,\-\.\/0-9:;\<=>\?\@A-Z\[\]\^\_\`a-z\{\|\}\~\t\v\r\n\a\f\b]
charesc  \\[\'tvrnafb\\]
stresc   \\[\'\"tvrnafb\\]
notstresc \\[^\'\"tvrnafb\\]

%%
  /*
    Pattern definitions for all tokens 
  */
&&                         { cout << yytext; return T_AND; }
=                          { cout << yytext; return T_ASSIGN; }
bool                       { cout << yytext; return T_BOOLTYPE; }
break                      { cout << yytext; return T_BREAK; }
('{chars}')|('{charesc}')  { cout << yytext; yylval.number = get_charconstant(yytext); return T_CHARCONSTANT; }
class                      { cout << yytext; return T_CLASS; }
,                          { cout << yytext; return T_COMMA; }
\/\/[^\n]*\n               { cout << yytext; process_ws(); } /* ignore comments */
continue                   { cout << yytext; return T_CONTINUE; }
\/                         { cout << yytext; return T_DIV; }
\.                         { cout << yytext; return T_DOT; }
 else                      { cout << yytext; return T_ELSE; }
==                         { cout << yytext; return T_EQ; }
extends                    { cout << yytext; return T_EXTENDS; }
extern                     { cout << yytext; return T_EXTERN; }
false                      { cout << yytext; return T_FALSE; }
for                        { cout << yytext; return T_FOR; }
>=                         { cout << yytext; return T_GEQ; }
>                          { cout << yytext; return T_GT; }
if                         { cout << yytext; return T_IF; }
(0x[0-9a-fA-F]+)|([0-9]+)  { cout << yytext; yylval.number = get_intconstant(yytext); return T_INTCONSTANT; }
int                        { cout << yytext; return T_INTTYPE; }
\{                         { cout << yytext; return T_LCB; }
\<\<                       { cout << yytext; return T_LEFTSHIFT; }
\<=                        { cout << yytext; return T_LEQ; }
\(                         { cout << yytext; return T_LPAREN; }
\[                         { cout << yytext; return T_LSB; }
\<                         { cout << yytext; return T_LT; }
-                          { cout << yytext; return T_MINUS; }
\%                         { cout << yytext; return T_MOD; }
\*                         { cout << yytext; return T_MULT; }
!=                         { cout << yytext; return T_NEQ; }
new                        { cout << yytext; return T_NEW; }
!                          { cout << yytext; return T_NOT; }
null                       { cout << yytext; return T_NULL; }
\|\|                       { cout << yytext; return T_OR; }
\+                         { cout << yytext; return T_PLUS; }
\}                         { cout << yytext; return T_RCB; }
return                     { cout << yytext; return T_RETURN; }
>>                         { cout << yytext; return T_RIGHTSHIFT; }
\)                         { cout << yytext; return T_RPAREN; }
\]                         { cout << yytext; return T_RSB; }
\;                         { cout << yytext; return T_SEMICOLON; }
string                     { cout << yytext; return T_STRINGTYPE; }
\"([^\n\"\\]*{stresc}?)*\" { cout << yytext; yylval.sval = process_string(yytext); return T_STRINGCONSTANT; }
true                       { cout << yytext; return T_TRUE; }
void                       { cout << yytext; return T_VOID; }
while                      { cout << yytext; return T_WHILE; }
[a-zA-Z\_][a-zA-Z\_0-9]*   { cout << yytext; yylval.sval = new string(yytext); return T_ID; } /* note that identifier pattern must be after all keywords */
[\t\r\n\a\v\b ]+           { cout << yytext; process_ws(); } /* ignore whitespace */
  /* 
   Error handling
   (be careful: error patterns should not match more input than a valid token)
  */
\"([^\n\"\\]*{notstresc}?)*\" { cerr << "Error: unknown escape sequence in string constant" << endl; return -1; }
\"\"\"                     { cerr << "Error: unterminated string constant" << endl; return -1; }
\"([^\n\"\\]*{notstresc}?)*\n { cerr << "Error: newline in string constant" << endl; return -1; }
\"([^\n\"\\]*{stresc}?)*$  { cerr << "Error: string constant is missing closing delimiter" << endl; return -1; }
'[^\\]{chars}'             { cerr << "Error: char constant length is greater than one" << endl; return -1; }
'\\'                       { cerr << "Error: unterminated char constant" << endl; return -1; }
''                         { cerr << "Error: char constant has zero width" << endl; return -1; }
.                          { cerr << "Error: unexpected character in input" << endl; return -1; }

%%

int getLineNumber() {
  return lineno;
}

int yyerror(const char *s) {
  cerr << lineno << ": " << s << " at " << yytext << endl;
  return 1;
}
