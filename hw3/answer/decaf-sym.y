%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "decaf-sym.h"
#include "symTable.cc"

int yylex(void);
int yyerror(char *);
int getLineNumber(); 

using namespace std;

symTable* tableList;
int currVarType;
string currVarName;

void printVarUsage(string name) {
    descriptor *var = tableList->getSymbol(name);
    if(var != NULL) {
        cout << " // using decl on line: " << var->getLineNum();
    }else {
        cerr << " // using variable that is not decalred in scope" << endl;
        exit(1);
    }
}

%}

%union{
    std::string *sval;
    int number;
    int decaftype;
 }

%token T_AND T_ASSIGN T_BREAK T_CLASS T_COMMENT T_COMMA T_CONTINUE T_DIV T_DOT T_ELSE T_EQ T_EXTENDS T_EXTERN 
%token T_FOR T_GEQ T_GT T_IF T_LCB T_LEFTSHIFT T_LEQ T_LPAREN T_LSB T_LT T_MINUS T_MOD T_MULT T_NEQ T_NEW T_NOT 
%token T_NULL T_OR T_PLUS T_RCB T_RETURN T_RIGHTSHIFT T_RPAREN T_RSB T_SEMICOLON T_STRINGTYPE
%token T_VOID T_WHILE T_WHITESPACE
%token T_INTTYPE T_BOOLTYPE

%token <number> T_CHARCONSTANT T_INTCONSTANT T_FALSE T_TRUE 
%token <sval> T_ID T_STRINGCONSTANT

%left T_OR
%left T_AND
%left T_EQ T_NEQ T_LT T_LEQ T_GEQ T_GT
%left T_PLUS T_MINUS
%left T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%left T_NOT
%right UMINUS

%%

start: program

program: extern_list decafclass

extern_list: extern_list extern_defn
    | /* extern_list can be empty */
    ;

extern_defn: T_EXTERN method_type T_ID T_LPAREN extern_type_list T_RPAREN T_SEMICOLON
    | T_EXTERN method_type T_ID T_LPAREN T_RPAREN T_SEMICOLON
    ;

extern_type_list: extern_type
    | extern_type T_COMMA extern_type_list
    ;

extern_type: T_STRINGTYPE
    | type
    ;

decafclass: T_CLASS T_ID T_LCB block_start field_decl_list method_decl_list T_RCB block_end
    | T_CLASS T_ID T_LCB block_start field_decl_list T_RCB block_end
    ;

block_start: /* empty */
    { tableList->addTable(); }
    ;

block_end: /* empty */
    { tableList->removeTable(); }
    ;    

field_decl_list: field_decl_list field_decl
    | /* empty */
    ;

field_decl: field_list T_SEMICOLON
    | type T_ID T_ASSIGN constant T_SEMICOLON { tableList->addSymbol(*$2, currVarType, 0, 0, getLineNumber(), false); }
    ;

field_list: field_list T_COMMA T_ID { tableList->addSymbol(*$3, currVarType, 0, 0, getLineNumber(), false); }
    | field_list T_COMMA T_ID T_LSB T_INTCONSTANT T_RSB { tableList->addSymbol(*$3, currVarType, 0, 0, getLineNumber(), false); }
    | type T_ID { tableList->addSymbol(*$2, currVarType, 0, 0, getLineNumber(), false); }
    | type T_ID T_LSB T_INTCONSTANT T_RSB { tableList->addSymbol(*$2, currVarType, 0, 0, getLineNumber(), false); }
    ;

method_decl_list: method_decl_list method_decl 
    | method_decl
    ;

method_decl: T_VOID T_ID T_LPAREN block_start param_list T_RPAREN method_block block_end
    | type T_ID T_LPAREN block_start param_list T_RPAREN method_block block_end
    ;

method_type: T_VOID
    | type
    ;

param_list: param_comma_list
    | /* empty */
    ;

param_comma_list: type T_ID { tableList->addSymbol(*$2, currVarType, 0, 0, getLineNumber(), false); } T_COMMA param_comma_list
    | type T_ID { tableList->addSymbol(*$2, currVarType, 0, 0, getLineNumber(), false); }
    ;

type: T_INTTYPE { currVarType = descriptor::INT_TYPE; }
    | T_BOOLTYPE { currVarType = descriptor::BOOL_TYPE; }
    ;

block: T_LCB block_start var_decl_list statement_list T_RCB block_end

method_block: T_LCB var_decl_list statement_list T_RCB

var_decl_list: var_decl var_decl_list
    | /* empty */
    ;

var_decl: var_list T_SEMICOLON

var_list: var_list T_COMMA T_ID { tableList->addSymbol(*$3, currVarType, 0, 0, getLineNumber(), false); }
    | type T_ID { tableList->addSymbol(*$2, currVarType, 0, 0, getLineNumber(), false); }
    ;

statement_list: statement statement_list
    | /* empty */ 
    ;

statement: assign T_SEMICOLON { printVarUsage(currVarName); }
    | method_call T_SEMICOLON
    | T_IF T_LPAREN expr T_RPAREN block T_ELSE block
    | T_IF T_LPAREN expr T_RPAREN block 
    | T_WHILE T_LPAREN expr T_RPAREN block
    | T_FOR T_LPAREN assign_comma_list T_SEMICOLON expr T_SEMICOLON assign_comma_list T_RPAREN block
    | T_RETURN T_LPAREN expr T_RPAREN T_SEMICOLON
    | T_RETURN T_LPAREN T_RPAREN T_SEMICOLON
    | T_RETURN T_SEMICOLON
    | T_BREAK T_SEMICOLON
    | T_CONTINUE T_SEMICOLON
    | block
    ;

assign: T_ID T_ASSIGN expr {currVarName = *$1;}
    | T_ID T_LSB expr T_RSB T_ASSIGN expr { currVarName = *$1; }
    ;

method_call: T_ID T_LPAREN method_arg_list T_RPAREN
    | T_ID T_LPAREN T_RPAREN
    ;

method_arg_list: method_arg
    | method_arg T_COMMA method_arg_list
    ;

method_arg: expr
    | T_STRINGCONSTANT
    ;
   
assign_comma_list: assign { printVarUsage(currVarName); }
    | assign { printVarUsage(currVarName); } T_COMMA assign_comma_list
    ;

rvalue: T_ID { printVarUsage(*$1); }
    | T_ID { printVarUsage(*$1); } T_LSB expr T_RSB
    ;

expr: rvalue
    | method_call
    | constant
    | expr T_PLUS expr
    | expr T_MINUS expr
    | expr T_MULT expr
    | expr T_DIV expr
    | expr T_LEFTSHIFT expr
    | expr T_RIGHTSHIFT expr
    | expr T_MOD expr
    | expr T_LT expr
    | expr T_GT expr
    | expr T_LEQ expr
    | expr T_GEQ expr
    | expr T_EQ expr
    | expr T_NEQ expr
    | expr T_AND expr
    | expr T_OR expr
    | T_MINUS expr %prec UMINUS 
    | T_NOT expr
    | T_LPAREN expr T_RPAREN
    ;

constant: T_INTCONSTANT
    | T_CHARCONSTANT
    | bool_constant
    ;

bool_constant: T_TRUE
    | T_FALSE 
    ;

%%

int main() {
  currVarType = 0;
  currVarName = "";
  tableList = new symTable(); 
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  return(retval >= 1 ? 1 : 0);
}
