%{
#include "decaf-defs.h"
#include "decaf-ast.tab.h"
#include <cstring>
#include <string>
#include <sstream>
#include <iostream>

    using namespace std;

    int lineno = 1;
    int tokenpos = 1;

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

%%

\&\&                            { return T_AND;              }
\|\|                            { return T_OR;               }
\=                              { return T_ASSIGN;           }
\+                              { return T_PLUS;             }
\-                              { return T_MINUS;            }
\*                              { return T_MULT;             }
\/                              { return T_DIV;              }
\%                              { return T_MOD;              }
\>                              { return T_GT;               }
\>\=                            { return T_GEQ;              }
\=\=                            { return T_EQ;               }
\!\=                            { return T_NEQ;              }
\<\=                            { return T_LEQ;              }
\<                              { return T_LT;               }
\<\<                            { return T_LEFTSHIFT;        }
\>\>                            { return T_RIGHTSHIFT;       }
\!                              { return T_NOT;              }
\(                              { return T_LPAREN;           }
\)                              { return T_RPAREN;           }
\[                              { return T_LSB;              }
\]                              { return T_RSB;              }
\{                              { return T_LCB;              }
\}                              { return T_RCB;              }
\.                              { return T_DOT;              }
\,                              { return T_COMMA;            }
\;                              { return T_SEMICOLON;        }
bool                            { return T_BOOLTYPE;         }
break                           { return T_BREAK;            }
class                           { return T_CLASS;            }
continue                        { return T_CONTINUE;         }
else                            { return T_ELSE;             }
extends                         { return T_EXTENDS;          }
extern                          { return T_EXTERN;           }
false                           { return T_FALSE;            }
for                             { return T_FOR;              }
if                              { return T_IF;               }
int                             { return T_INTTYPE;          }
new                             { return T_NEW;              }
null                            { return T_NULL;             }
return                          { return T_RETURN;           }
string                          { return T_STRINGTYPE;       }
true                            { return T_TRUE;             }
void                            { return T_VOIDTYPE;         }
while                           { return T_WHILE;            }
\/\/.*                          /* do nothing */
(0x[0-9a-fA-F]+)|([0-9]+)       { yylval.number = get_intconstant(yytext);  return T_INTCONSTANT;       }
('{chars}')|('{charesc}')       { yylval.number = get_charconstant(yytext); return T_CHARCONSTANT;      }
\"([^\n\"\\]*{stresc}?)*\"      { yylval.sval = process_string(yytext);     return T_STRINGCONSTANT;    }
[a-zA-Z\_][a-zA-Z\_0-9]*        { yylval.sval = new string(yytext);         return T_ID;                }
[\t\r\n\a\v\b ]+                { process_ws();                                                         }
.                               { cerr << "Error: unexpected character in input" << endl; return -1;    }

%%

int yyerror(const char *s) {
    cerr << lineno << ": " << s << " at " << yytext << endl;
    return 1;
}
