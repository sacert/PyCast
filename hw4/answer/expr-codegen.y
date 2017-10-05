%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "decafdefs.h"

using namespace std;
typedef llvm::Value descriptor;

#include "symboltable.cc"

// print AST?
bool printAST = false;

// syms contains all the variable names used
symboltable syms;

// this global variable contains all the generated code
static llvm::Module *TheModule;

// this is the method used to construct the LLVM intermediate code (IR)
static llvm::IRBuilder<> Builder(llvm::getGlobalContext());
// the calls to getGlobalContext() in the init above and in the
// following code ensures that we are incrementally generating
// instructions in the right order

#include "decaf-ast.cc"
#include "llvm-codegen.cc"

void enter_symtbl(string ident, int typesize) {
  llvm::AllocaInst *Alloca;
  llvm::Function *F = Builder.GetInsertBlock()->getParent();
  Alloca = Builder.CreateAlloca(llvm::IntegerType::get(llvm::getGlobalContext(), typesize), 0, ident.c_str());
  syms.enter_symtbl(ident, Alloca);
}

%}

%union{
    class decafAST *ast;
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

%type <decaftype> type method_type extern_type
%type <ast> rvalue expr constant bool_constant method_call method_arg method_arg_list assign assign_comma_list
%type <ast> block method_block statement statement_list var_decl_list var_decl var_list param_list param_comma_list
%type <ast> method_decl method_decl_list field_decl_list field_decl field_list extern_type_list extern_defn
%type <ast> extern_list decafclass

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
    {
        ProgramAST *prog = new ProgramAST((decafStmtList *)$1, (ClassAST *)$2);
		if (printAST) {
			cout << getString(prog) << endl;
		}
        try {
            prog->Codegen();
        }
        catch (std::runtime_error &e) {
            cout << "semantic error: " << e.what() << endl;
            //cout << prog->str() << endl;
            exit(EXIT_FAILURE);
        }
        delete prog;
    }

extern_list: extern_list extern_defn
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_front($2); $$ = slist; }
    | /* extern_list can be empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

extern_defn: T_EXTERN method_type T_ID T_LPAREN extern_type_list T_RPAREN T_SEMICOLON
    { $$ = new ExternAST((decafType)$2, *$3, (TypedSymbolListAST *)$5); delete $3; }
    | T_EXTERN method_type T_ID T_LPAREN T_RPAREN T_SEMICOLON
    { $$ = new ExternAST((decafType)$2, *$3, NULL); delete $3; }
    ;

extern_type_list: extern_type
    { $$ = new TypedSymbolListAST(string(""), (decafType)$1); }
    | extern_type T_COMMA extern_type_list
    {
        TypedSymbolListAST *tlist = (TypedSymbolListAST *)$3;
        tlist->push_front(string(""), (decafType)$1);
        $$ = tlist;
    }
    ;

extern_type: T_STRINGTYPE
    { $$ = stringTy; }
    | type
    { $$ = $1; }
    ;

decafclass: T_CLASS T_ID T_LCB field_decl_list method_decl_list T_RCB
    { $$ = new ClassAST(*$2, (FieldDeclListAST *)$4, (decafStmtList *)$5); delete $2; }
    | T_CLASS T_ID T_LCB field_decl_list T_RCB
    { $$ = new ClassAST(*$2, (FieldDeclListAST *)$4, new decafStmtList()); delete $2; }
    ;

field_decl_list: field_decl_list field_decl
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
    | /* empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

field_decl: field_list T_SEMICOLON
    { $$ = $1; }
    | type T_ID T_ASSIGN constant T_SEMICOLON
    { $$ = new AssignGlobalVarAST((decafType)$1, *$2, $4); delete $2; }
    ;

field_list: field_list T_COMMA T_ID
    { FieldDeclListAST *flist = (FieldDeclListAST *)$1; flist->new_sym(*$3, -1); $$ = flist; delete $3; }
    | field_list T_COMMA T_ID T_LSB T_INTCONSTANT T_RSB
    { FieldDeclListAST *flist = (FieldDeclListAST *)$1; flist->new_sym(*$3, $5); $$ = flist; delete $3; }
    | type T_ID
    { $$ = new FieldDeclListAST(*$2, (decafType)$1, -1); delete $2; }
    | type T_ID T_LSB T_INTCONSTANT T_RSB
    {
        if ( $4 == 0 ){
            throw runtime_error("array size can not be 0\n");
        }
        $$ = new FieldDeclListAST(*$2, (decafType)$1, $4); delete $2;
    }
    ;

method_decl_list: method_decl_list method_decl
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
    | method_decl
    { decafStmtList *slist = new decafStmtList(); slist->push_back($1); $$ = slist; }
    ;

method_decl: T_VOID T_ID T_LPAREN param_list T_RPAREN method_block
    { $$ = new MethodDeclAST(voidTy, *$2, (TypedSymbolListAST *)$4, (MethodBlockAST *)$6); delete $2; }
    | type T_ID T_LPAREN param_list T_RPAREN method_block
    { $$ = new MethodDeclAST((decafType)$1, *$2, (TypedSymbolListAST *)$4, (MethodBlockAST *)$6); delete $2; }
    ;

method_type: T_VOID
    { $$ = voidTy; }
    | type
    { $$ = $1; }
    ;

param_list: param_comma_list
    { $$ = $1; }
    | /* empty */
    { $$ = NULL; }
    ;

param_comma_list: type T_ID T_COMMA param_comma_list
    {
        TypedSymbolListAST *tlist = (TypedSymbolListAST *)$4;
        tlist->push_front(*$2, (decafType)$1);
        $$ = tlist;
        delete $2;
    }
    | type T_ID
    { $$ = new TypedSymbolListAST(*$2, (decafType)$1); delete $2; }
    ;

type: T_INTTYPE
    { $$ = intTy; }
    | T_BOOLTYPE
    { $$ = boolTy; }
    ;

block: T_LCB var_decl_list statement_list T_RCB
    { $$ = new BlockAST((decafStmtList *)$2, (decafStmtList *)$3); }

method_block: T_LCB var_decl_list statement_list T_RCB
    { $$ = new MethodBlockAST((decafStmtList *)$2, (decafStmtList *)$3); }

var_decl_list: var_decl var_decl_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

var_decl: var_list T_SEMICOLON
    { $$ = $1; }

var_list: var_list T_COMMA T_ID
    {
        TypedSymbolListAST *tlist = (TypedSymbolListAST *)$1;
        tlist->new_sym(*$3);
        $$ = tlist;
        delete $3;
    }
    | type T_ID
    { $$ = new TypedSymbolListAST(*$2, (decafType)$1); delete $2; }
    ;

statement_list: statement statement_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

statement: assign T_SEMICOLON
    { $$ = $1; }
    | method_call T_SEMICOLON
    { $$ = $1; }
    | T_IF T_LPAREN expr T_RPAREN block T_ELSE block
    { $$ = new IfStmtAST($3, (BlockAST *)$5, (BlockAST *)$7); }
    | T_IF T_LPAREN expr T_RPAREN block
    { $$ = new IfStmtAST($3, (BlockAST *)$5, NULL); }
    | T_WHILE T_LPAREN expr T_RPAREN block
    { $$ = new WhileStmtAST($3, (BlockAST *)$5); }
    | T_FOR T_LPAREN assign_comma_list T_SEMICOLON expr T_SEMICOLON assign_comma_list T_RPAREN block
    { $$ = new ForStmtAST((decafStmtList *)$3, $5, (decafStmtList *)$7, (BlockAST *)$9); }
    | T_RETURN T_LPAREN expr T_RPAREN T_SEMICOLON
    { $$ = new ReturnStmtAST($3); }
    | T_RETURN T_LPAREN T_RPAREN T_SEMICOLON
    { $$ = new ReturnStmtAST(NULL); }
    | T_RETURN T_SEMICOLON
    { $$ = new ReturnStmtAST(NULL); }
    | T_BREAK T_SEMICOLON
    { $$ = new BreakStmtAST(); }
    | T_CONTINUE T_SEMICOLON
    { $$ = new ContinueStmtAST(); }
    | block
    { $$ = $1; }
    ;

assign: T_ID T_ASSIGN expr
    { $$ = new AssignVarAST(*$1, $3); delete $1; }
    | T_ID T_LSB expr T_RSB T_ASSIGN expr
    { $$ = new AssignArrayLocAST(*$1, $3, $6); delete $1; }
    ;

method_call: T_ID T_LPAREN method_arg_list T_RPAREN
    { $$ = new MethodCallAST(*$1, (decafStmtList *)$3); delete $1; }
    | T_ID T_LPAREN T_RPAREN
    { $$ = new MethodCallAST(*$1, (decafStmtList *)NULL); delete $1; }
    ;

method_arg_list: method_arg
    { decafStmtList *slist = new decafStmtList(); slist->push_front($1); $$ = slist; }
    | method_arg T_COMMA method_arg_list
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist; }
    ;

method_arg: expr
    { $$ = $1; }
    | T_STRINGCONSTANT
    { $$ = new StringConstAST(*$1); delete $1; }
    ;

assign_comma_list: assign
    { decafStmtList *slist = new decafStmtList(); slist->push_front($1); $$ = slist; }
    | assign T_COMMA assign_comma_list
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist; }
    ;

rvalue: T_ID
    { $$ = new VariableExprAST(*$1); delete $1; }
    | T_ID T_LSB expr T_RSB
    { $$ = new ArrayLocExprAST(*$1, $3); delete $1; }
    ;

expr: rvalue
    { $$ = $1; }
    | method_call
    { $$ = $1; }
    | constant
    { $$ = $1; }
    | expr T_PLUS expr
    { $$ = new BinaryExprAST(T_PLUS, $1, $3); }
    | expr T_MINUS expr
    { $$ = new BinaryExprAST(T_MINUS, $1, $3); }
    | expr T_MULT expr
    { $$ = new BinaryExprAST(T_MULT, $1, $3); }
    | expr T_DIV expr
    { $$ = new BinaryExprAST(T_DIV, $1, $3); }
    | expr T_LEFTSHIFT expr
    { $$ = new BinaryExprAST(T_LEFTSHIFT, $1, $3); }
    | expr T_RIGHTSHIFT expr
    { $$ = new BinaryExprAST(T_RIGHTSHIFT, $1, $3); }
    | expr T_MOD expr
    { $$ = new BinaryExprAST(T_MOD, $1, $3); }
    | expr T_LT expr
    { $$ = new BinaryExprAST(T_LT, $1, $3); }
    | expr T_GT expr
    { $$ = new BinaryExprAST(T_GT, $1, $3); }
    | expr T_LEQ expr
    { $$ = new BinaryExprAST(T_LEQ, $1, $3); }
    | expr T_GEQ expr
    { $$ = new BinaryExprAST(T_GEQ, $1, $3); }
    | expr T_EQ expr
    { $$ = new BinaryExprAST(T_EQ, $1, $3); }
    | expr T_NEQ expr
    { $$ = new BinaryExprAST(T_NEQ, $1, $3); }
    | expr T_AND expr
    { $$ = new BinaryExprAST(T_AND, $1, $3); }
    | expr T_OR expr
    { $$ = new BinaryExprAST(T_OR, $1, $3); }
    | T_MINUS expr %prec UMINUS
    { $$ = new UnaryExprAST(T_MINUS, $2); }
    | T_NOT expr
    { $$ = new UnaryExprAST(T_NOT, $2); }
    | T_LPAREN expr T_RPAREN
    { $$ = $2; }
    ;

constant: T_INTCONSTANT
    { $$ = new NumberExprAST($1); }
    | T_CHARCONSTANT
    { $$ = new NumberExprAST($1); }
    | bool_constant
    { $$ = $1; }
    ;

bool_constant: T_TRUE
    { $$ = new BoolExprAST(true); }
    | T_FALSE
    { $$ = new BoolExprAST(false); }
    ;

%%

int main() {
  // initialize LLVM
  llvm::LLVMContext &Context = llvm::getGlobalContext();
  // Make the module, which holds all the code.
  TheModule = new llvm::Module("Test", Context);
  // set up symbol table
  syms.new_symtbl();
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  // remove symbol table
  //syms.pop_symtbl();
  /*
	if (0 != yyparse()) {
	  throw runtime_error("syntax error\n");
    }
  */
  // remove symbol table
  syms.remove_symtbl();
  // Print out all of the generated code to stderr
  TheModule->dump();
  return(retval >= 1 ? 1 : 0);
}
