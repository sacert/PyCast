%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include <sstream>
#include "decaf-defs.h"

int yylex(void);
int yyerror(char *);

using namespace std;

// print AST?
bool printAST = true;
string ids = "";

#include "decaf-ast.cc"

%}

%union{
    class decafAST *ast;
    std::string *sval;
    int number;
    int decaftype;
}

%token T_ASSIGN
%token T_LPAREN T_RPAREN T_LSB T_RSB T_LCB T_RCB
%token T_DOT T_COMMA T_SEMICOLON
%token T_BREAK T_CLASS T_CONTINUE T_ELSE T_EXTENDS T_EXTERN T_FOR T_IF T_NEW T_RETURN T_WHILE T_NULL
%token T_BOOLTYPE T_INTTYPE T_STRINGTYPE T_VOIDTYPE

%token <number> T_CHARCONSTANT T_INTCONSTANT T_TRUE T_FALSE
%token <sval> T_ID T_STRINGCONSTANT

%type <sval> block_vars ids
%type <ast> externs extern_defn extern_types extern_type method_type type expr return_statement
%type <ast> field_decls method_decls constant block method_block method_params bool_constant method_decl
%type <ast> var_decls var_decl statements statement else_block assigns assign method_call method_args method_arg

%left T_OR
%left T_AND
%left T_GT T_GEQ T_EQ T_NEQ T_LEQ T_LT
%left T_PLUS T_MINUS
%left T_LEFTSHIFT T_RIGHTSHIFT
%left T_MULT T_DIV T_MOD
%precedence UMINUS T_NOT

%%
program             : externs T_CLASS T_ID T_LCB field_decls method_decls T_RCB
                        {
                             ClassAST *cls = new ClassAST(*$3, (decafStmtList *)$5, (decafStmtList *)$6);
                             ProgramAST *prog = new ProgramAST((decafStmtList *)$1, cls);
                             if (printAST) {
                                  cout << getString(prog) << endl;
                             }
                             delete prog;
                        }
                    ;
externs             :
                        { decafStmtList *slist = new decafStmtList(); $$ = slist; }
                    | extern_defn externs
                        { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
                    ;
extern_defn         : T_EXTERN method_type T_ID T_LPAREN T_RPAREN T_SEMICOLON
                        {
                             $$ = new ExternAST(*$3, (decafAST *)$2, new decafStmtList());
                        }
                    | T_EXTERN method_type T_ID T_LPAREN extern_types T_RPAREN T_SEMICOLON
                        {
                             $$ = new ExternAST(*$3, (decafAST *)$2, (decafStmtList *)$5);
                        }
                    ;
extern_types        : extern_type
                        { decafStmtList *tlist = new decafStmtList(); tlist->push_front($1); $$ = tlist; }
                    | extern_type T_COMMA extern_types
                        { decafStmtList *tlist = (decafStmtList *)$3; tlist->push_front($1); $$ = tlist; }
                    ;
extern_type         : T_STRINGTYPE
                        { $$ = new TypedSymbolAST("", new TypeAST(T_STRINGTYPE)); }
                    | T_VOIDTYPE
                        { $$ = new TypedSymbolAST("", new TypeAST(T_VOIDTYPE)); }
                    | T_INTTYPE
                        { $$ = new TypedSymbolAST("", new TypeAST(T_INTTYPE)); }
                    | T_BOOLTYPE
                        { $$ = new TypedSymbolAST("", new TypeAST(T_BOOLTYPE)); }
                    ;
method_type         : T_VOIDTYPE
                        { $$ = new TypeAST(T_VOIDTYPE); }
                    | type
                        { $$ = $1; }
                    ;
type                : T_INTTYPE
                        { $$ = new TypeAST(T_INTTYPE); }
                    | T_BOOLTYPE
                        { $$ = new TypeAST(T_BOOLTYPE); }
                    ;
field_decls               :
                        { decafStmtList *list = new decafStmtList(); $$ =list; }
                    | type ids T_SEMICOLON field_decls
                        {
                            decafStmtList *list = (decafStmtList *)$4;
                            istringstream iss(*$2);
                            while(iss)
                            {
                                string sub;
                                iss >> sub;
                                if (sub != "" ){
                                    list->push_front(new FieldDeclAST(sub, $1, new FieldSizeAST(-1)));
                                }
                            }
                            $$ = list;
                        }
                    | type T_ID T_LSB T_INTCONSTANT T_RSB T_SEMICOLON field_decls
                        {
                            FieldDeclAST *fld = new FieldDeclAST(*$2, $1, new FieldSizeAST($4));
                            decafStmtList *list = (decafStmtList *)$7; list->push_front(fld); $$ =list;
                        }
                    | type T_ID T_ASSIGN constant T_SEMICOLON field_decls
                        {
                             AssignGlobalVarAST *asg = new AssignGlobalVarAST (*$2, $1, $4);
                             decafStmtList *list = (decafStmtList *)$6; list->push_front(asg); $$ =list;
                        }
                    | type T_ID T_LPAREN T_RPAREN method_block method_decls
                        {
                             MethodDeclAST *mtd = new MethodDeclAST (*$2, $1, new decafStmtList(), $5);
                             decafStmtList *list = (decafStmtList *)$6; list->push_front(mtd); $$ =list;
                        }
                    | type T_ID T_LPAREN method_params T_RPAREN method_block method_decls
                        {
                             MethodDeclAST *mtd = new MethodDeclAST (*$2, $1, (decafStmtList *) $4, $6);
                             decafStmtList *list = (decafStmtList *)$7; list->push_front(mtd); $$ =list;
                        }
                    ;
ids                 : T_ID
                        {
                            $$ = $1;
                        }
                    | T_ID T_COMMA ids
                        {
                            ids = *$1 + " " + *$3;
                            $$ = &ids;
                        }
                    ;
constant            : T_INTCONSTANT
                        {
                             $$ = new NumberExprAST($1);
                        }
                    | T_CHARCONSTANT
                        {
                             $$ = NULL;
                        }
                    | bool_constant
                        {
                             $$ = $1;
                        }
                    ;
bool_constant       : T_TRUE
                        {
                             $$ = new BoolExprAST(true);
                        }
                    | T_FALSE
                        {
                             $$ = new BoolExprAST(false);
                        }
                    ;
method_decls        :
                        {
                             decafStmtList *slist = new decafStmtList(); $$ = slist;
                        }
                    | method_decl method_decls
                        {
                             decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist;
                        }
                    ;
method_decl         : method_type T_ID T_LPAREN T_RPAREN method_block
                        {
                             $$ = new MethodDeclAST (*$2, $1, new decafStmtList(), $5);
                        }
                    | method_type T_ID T_LPAREN method_params T_RPAREN method_block
                        {
                             $$ = new MethodDeclAST (*$2, $1, (decafStmtList *)$4, $6);
                        }
                    ;
method_params       : type T_ID
                        {
                             TypedSymbolAST *tpsym = new TypedSymbolAST (*$2, $1);
                             decafStmtList *list = new decafStmtList(); list->push_front(tpsym); $$ = list;
                        }
                    | type T_ID T_COMMA method_params
                        {
                             TypedSymbolAST *tpsym = new TypedSymbolAST (*$2, $1);
                             decafStmtList *list = (decafStmtList *)$4; list->push_front(tpsym); $$ = list;
                        }
                    ;
block               : T_LCB var_decls statements T_RCB
                        {
                             $$ = new BlockAST((decafStmtList *)$2, (decafStmtList *)$3);
                        }
                    ;
method_block        : T_LCB var_decls statements T_RCB
                        {
                             $$ = new MethodBlockAST((decafStmtList *)$2, (decafStmtList *)$3);
                        }
                    ;
var_decls           :
                        {
                            decafStmtList *list = new decafStmtList();
                            $$ = list;
                        }
                    | var_decl var_decls
                        {
                            decafStmtList *list = (decafStmtList *)$2;
                            list->push_front($1);
                            $$ = list;
                        }
                    ;
var_decl            : type block_vars T_SEMICOLON
                        {
                            decafStmtList *list = new decafStmtList();
                            istringstream iss(*$2);
                            while (iss){
                                string sub;
                                iss >> sub;
                                if (sub != ""){
                                    list->push_front(new TypedSymbolAST(sub, $1));
                                }
                            }
                            $$ = list;
                        }
                    ;
block_vars          : T_ID T_COMMA block_vars
                        {
                            ids = *$1 + " " + *$3;
                            $$ = &ids;
                        }
                    | T_ID
                        {
                            $$ = $1;
                        }
                    ;
statements          :
                        {
                             $$ = new decafStmtList();
                        }
                    | statement statements
                        {
                             decafStmtList *list = (decafStmtList *)$2; list->push_front($1); $$ = list;
                        }
                    ;
statement           : block
                        {
                             $$ = $1;
                        }
                    | assign T_SEMICOLON
                        {
                             $$ = $1;
                        }
                    | method_call T_SEMICOLON
                        {
                             $$ = $1;
                        }
                    | T_IF T_LPAREN expr T_RPAREN block else_block
                        {
                             $$ = new IfStmtAST($3, $5, $6);
                        }
                    | T_WHILE T_LPAREN expr T_RPAREN block
                        {
                             $$ = new WhileStmtAST($3, $5);
                        }
                    | T_FOR T_LPAREN assigns T_SEMICOLON expr T_SEMICOLON assigns T_RPAREN block
                        {
                             $$ = new ForStmtAST((decafStmtList *)$3, $5, (decafStmtList *)$7, $9);
                        }
                    | return_statement
                        {
                             $$ = $1;
                        }
                    | T_BREAK T_SEMICOLON
                        {
                             $$ = new BreakStmtAST();
                        }
                    | T_CONTINUE T_SEMICOLON
                        {
                             $$ = new ContinueStmtAST();
                        }
                    ;
else_block          :
                        {
                             $$ = NULL;
                        }
                    | T_ELSE block
                        {
                             $$ = $2;
                        }
                    ;
return_statement    : T_RETURN T_SEMICOLON
                        {
                             $$ = new ReturnStmtAST(NULL);
                        }
                    | T_RETURN T_LPAREN T_RPAREN T_SEMICOLON
                        {
                             $$ = new ReturnStmtAST(NULL);
                        }
                    | T_RETURN T_LPAREN expr T_RPAREN T_SEMICOLON
                        {
                             $$ = new ReturnStmtAST($3);
                        }
                    ;
assigns             : assign T_COMMA assigns
                        {
                            decafStmtList *list = (decafStmtList *)$3;
                            list->push_front($1);
                            $$ = list;
                        }
                    | assign
                        {
                            decafStmtList *list = new decafStmtList();
                            list->push_front($1);
                            $$ = list;
                        }
assign              : T_ID T_ASSIGN expr
                        {
                            $$ = new AssignVarAST(*$1, $3);
                        }
                    | T_ID T_LSB expr T_RSB T_ASSIGN expr
                        {
                            $$ = new AssignArrayLocAST(*$1, $3, $6);
                        }
                    ;
method_call         : T_ID T_LPAREN T_RPAREN
                        {
                            $$ = new MethodCallAST(*$1, new decafStmtList());
                        }
                    | T_ID T_LPAREN method_args T_RPAREN
                        {
                            $$ = new MethodCallAST(*$1, (decafStmtList *)$3);
                        }
                    ;
method_args         : method_arg T_COMMA method_args
                        {
                            decafStmtList *list = (decafStmtList *)$3;
                            list->push_front($1);
                            $$ = list;
                        }
                    | method_arg
                        {
                            decafStmtList *list = new decafStmtList();
                            list->push_front($1);
                            $$ = list;
                        }
                    ;
method_arg          : expr
                        {
                            $$ = $1;
                        }
                    | T_STRINGCONSTANT
                        {
                            $$ = new StringConstantAST(*$1);
                        }
                    ;
expr                : T_ID
                        {
                            $$ = new VariableExprAST(*$1);
                        }
                    | method_call
                        {
                            $$ = $1;
                        }
                    | constant
                        {
                            $$ = $1;
                        }
                    | expr T_PLUS expr
                        {
                            $$ = new BinaryExprAST(T_PLUS, $1, $3);
                        }
                    | expr T_MINUS expr
                        {
                            $$ = new BinaryExprAST(T_MINUS, $1, $3);
                        }
                    | expr T_MULT expr
                        {
                            $$ = new BinaryExprAST(T_MULT, $1, $3);
                        }
                    | expr T_DIV expr
                        {
                            $$ = new BinaryExprAST(T_DIV, $1, $3);
                        }
                    | expr T_LEFTSHIFT expr
                        {
                            $$ = new BinaryExprAST(T_LEFTSHIFT, $1, $3);
                        }
                    | expr T_RIGHTSHIFT expr
                        {
                            $$ = new BinaryExprAST(T_RIGHTSHIFT, $1, $3);
                        }
                    | expr T_MOD expr
                        {
                            $$ = new BinaryExprAST(T_MOD, $1, $3);
                        }
                    | expr T_EQ expr
                        {
                            $$ = new BinaryExprAST(T_EQ, $1, $3);
                        }
                    | expr T_NEQ expr
                        {
                            $$ = new BinaryExprAST(T_NEQ, $1, $3);
                        }
                    | expr T_LT expr
                        {
                            $$ = new BinaryExprAST(T_LT, $1, $3);
                        }
                    | expr T_LEQ expr
                        {
                            $$ = new BinaryExprAST(T_LEQ, $1, $3);
                        }
                    | expr T_GT expr
                        {
                            $$ = new BinaryExprAST(T_GT, $1, $3);
                        }
                    | expr T_GEQ expr
                        {
                            $$ = new BinaryExprAST(T_GEQ, $1, $3);
                        }
                    | expr T_AND expr
                        {
                            $$ = new BinaryExprAST(T_AND, $1, $3);
                        }
                    | expr T_OR expr
                        {
                            $$ = new BinaryExprAST(T_OR, $1, $3);
                        }
                    | T_NOT expr
                        {
                            $$ = new UnaryExprAST(T_NOT, $2);
                        }
                    | T_MINUS expr %prec UMINUS
                        {
                            $$ = new UnaryExprAST(T_MINUS, $2);
                        }
                    | T_LPAREN expr T_RPAREN
                        {
                            $$ = $2;
                        }
                    | T_ID T_LSB expr T_RSB
                        {
                            $$ = new ArrayLocExprAST(*$1, $3, NULL);
                        }
                    ;
%%

int main() {
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  return(retval >= 1 ? 1 : 0);
}
