%{
#include "llvm/Analysis/Verifier.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include <cstdio>
#include <stdexcept>
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "decafast-defs.h"
#include "symbolTable.cc"

using namespace llvm;

int yylex(void);
int yyerror(char *);

static Module *TheModule;
static IRBuilder<> Builder(getGlobalContext());
static std::map<std::string, Value*> syms;
static symbolTable* table = new symbolTable();

typedef enum { voidTy, intTy, boolTy, stringTy, } decafType;

/// decafAST - Base class for all abstract syntax tree nodes.
class decafAST {
public:
  virtual ~decafAST() {}
  virtual Value *Codegen() = 0;
};

class TypedSymbol {
	string Sym;
	decafType Ty;
public:
	TypedSymbol(string s, decafType t) : Sym(s), Ty(t) {}
        string getIdent() {
            return Sym;
        }
        decafType getType() {
            return Ty;
        }
};

class TypedSymbolListAST : public decafAST {
	list<class TypedSymbol *> arglist;
	decafType listType; // this variable is used if all the symbols in the list share the same type
	AllocaInst* alloca = NULL;
public:
	TypedSymbolListAST() {}
	TypedSymbolListAST(string sym, decafType ty) {
		TypedSymbol *s = new TypedSymbol(sym, ty);
		arglist.push_front(s);
		listType = ty;
	}
	~TypedSymbolListAST() {
		for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
			delete *i;
		}
	}

	void push_front(string sym, decafType ty) {
		TypedSymbol *s = new TypedSymbol(sym, ty);
		arglist.push_front(s);
	}
	void push_back(string sym, decafType ty) {
		TypedSymbol *s = new TypedSymbol(sym, ty);
		arglist.push_back(s);
	}
	void new_sym(string sym) {
		if (arglist.empty()) {
			throw runtime_error("Error in AST creation: insertion into empty typed symbol list\n");
		}
		TypedSymbol *s = new TypedSymbol(sym, listType);
		arglist.push_back(s);
	}
        int size() {
            return arglist.size();
        }
	std::vector<class TypedSymbol *> getArgsList() {
            std::vector<class TypedSymbol *> arglistV;
            for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
                arglistV.push_back(*i);
            }
            return arglistV;
        }
        std::vector<Type*> getTypesOfArgs() {
            std::vector<Type*> args;
            for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
                switch ((*i)->getType()){
                    case voidTy:
                        args.push_back(Type::getVoidTy(getGlobalContext()));
                        break;
                    case intTy:
                        args.push_back(Type::getInt32Ty(getGlobalContext()));
                        break;
                    case boolTy:
                        args.push_back(Type::getInt1Ty(getGlobalContext()));
                        break;
                    case stringTy:
                        args.push_back(Type::getInt8PtrTy(getGlobalContext()));
                        break;
                    default:
                        break;
                }
	    }
            return args;
        }

        AllocaInst* getAlloc() {
        	return alloca;
        }

        virtual Value *Codegen();
};

/// decafStmtList - List of Decaf statements
class decafStmtList : public decafAST {
	list<decafAST *> stmts;
public:
	decafStmtList() {}
	~decafStmtList() {
		for (list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) {
			delete *i;
		}
	}
	int size() { return stmts.size(); }
	void push_front(decafAST *e) { stmts.push_front(e); }
	void push_back(decafAST *e) { stmts.push_back(e); }
        std::vector <Value*> getArgVector() {
            std::vector <Value*> rets;
            for (list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) {
                Value *v = (*i)->Codegen();
                if (v != 0) {
                    //std::cout << "I am here" << endl;
                    rets.push_back(v);
                }
            }
            return rets;
        }
        virtual Value *Codegen();
};

/// NumberExprAST - Expression class for integer numeric literals like "12".
class NumberExprAST : public decafAST {
	int Val;
public:
	NumberExprAST(int val) : Val(val) {}
        virtual Value *Codegen();
};

/// StringConstAST - string constant
class StringConstAST : public decafAST {
        string StringConst;
public:
	StringConstAST(string s) : StringConst(s) {}
        virtual Value *Codegen();
};

/// BoolExprAST - Expression class for boolean literals: "true" and "false".
class BoolExprAST : public decafAST {
	bool Val;
public:
	BoolExprAST(bool val) : Val(val) {}
        virtual Value *Codegen();
};

/// VariableExprAST - Expression class for variables like "a".
class VariableExprAST : public decafAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
        virtual Value *Codegen();
};

/// MethodCallAST - call a function with some arguments
class MethodCallAST : public decafAST {
	string Name;
	decafStmtList *Args;
        std::vector <Value*> Stmts;
public:
	MethodCallAST(string name, decafStmtList *args) : Name(name), Args(args) {}
	~MethodCallAST() { delete Args; }
        virtual Value *Codegen();
};

/// BinaryExprAST - Expression class for a binary operator.
class BinaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *LHS, *RHS;
public:
	BinaryExprAST(int op, decafAST *lhs, decafAST *rhs) : Op(op), LHS(lhs), RHS(rhs) {}
	~BinaryExprAST() { delete LHS; delete RHS; }
        virtual Value *Codegen();
};

/// UnaryExprAST - Expression class for a unary operator.
class UnaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *Expr;
public:
	UnaryExprAST(int op, decafAST *expr) : Op(op), Expr(expr) {}
	~UnaryExprAST() { delete Expr; }
        virtual Value *Codegen();
};

/// AssignVarAST - assign value to a variable
class AssignVarAST : public decafAST {
	string Name; // location to assign value
	decafAST *Val;
public:
	AssignVarAST(string name, decafAST *value) : Name(name), Val(value) {}
	~AssignVarAST() {
		if (Val != NULL) { delete Val; }
	}
        virtual Value *Codegen();
};

/// AssignArrayLocAST - assign value to a variable
class AssignArrayLocAST : public decafAST {
	string Name; // name of array variable
    decafAST *Index;  // index for assignment of value
	decafAST *Val;
public:
	AssignArrayLocAST(string name, decafAST *index, decafAST *value) : Name(name), Index(index), Val(value) {}
	~AssignArrayLocAST() { delete Index; delete Val; }
        virtual Value *Codegen();
};

/// ArrayLocExprAST - access an array location
class ArrayLocExprAST : public decafAST {
	string Name;
    decafAST *Expr;
public:
	ArrayLocExprAST(string name, decafAST *expr) : Name(name), Expr(expr) {}
	~ArrayLocExprAST() {
		if (Expr != NULL) { delete Expr; }
	}
        virtual Value *Codegen();
};

/// BlockAST - block
class BlockAST : public decafAST {
	decafStmtList *Vars;
	decafStmtList *Statements;
public:
	BlockAST(decafStmtList *vars, decafStmtList *s) : Vars(vars), Statements(s) {}
	~BlockAST() {
		if (Vars != NULL) { delete Vars; }
		if (Statements != NULL) { delete Statements; }
	}
	decafStmtList *getVars() { return Vars; }
	decafStmtList *getStatements() { return Statements; }
        virtual Value *Codegen();
};

/// MethodBlockAST - block for methods
class MethodBlockAST : public decafAST {
	decafStmtList *Vars;
	decafStmtList *Statements;
        BasicBlock *BB;
        decafType DT;
public:
	MethodBlockAST(decafStmtList *vars, decafStmtList *s) : Vars(vars), Statements(s) {}
	~MethodBlockAST() {
		if (Vars != NULL) { delete Vars; }
		if (Statements != NULL) { delete Statements; }
	}
        void setBasicBlock(BasicBlock *bb) {
            BB = bb;
        }
        void setReturnType(decafType ty) {
            DT = ty;
        }
        virtual Value *Codegen();
};

/// IfStmtAST - if statement
class IfStmtAST : public decafAST {
	decafAST *Cond;
	BlockAST *IfTrueBlock;
	BlockAST *ElseBlock;
public:
	IfStmtAST(decafAST *cond, BlockAST *iftrue, BlockAST *elseblock) : Cond(cond), IfTrueBlock(iftrue), ElseBlock(elseblock) {}
	~IfStmtAST() {
		delete Cond;
		delete IfTrueBlock;
		if (ElseBlock != NULL) { delete ElseBlock; }
	}
        virtual Value *Codegen();
};

/// WhileStmtAST - while statement
class WhileStmtAST : public decafAST {
	decafAST *Cond;
	BlockAST *Body;
public:
	WhileStmtAST(decafAST *cond, BlockAST *body) : Cond(cond), Body(body) {}
	~WhileStmtAST() { delete Cond; delete Body; }
        virtual Value *Codegen();
};

/// ForStmtAST - for statement
class ForStmtAST : public decafAST {
	decafStmtList *InitList;
	decafAST *Cond;
	decafStmtList *LoopEndList;
	BlockAST *Body;
public:
	ForStmtAST(decafStmtList *init, decafAST *cond, decafStmtList *end, BlockAST *body) :
		InitList(init), Cond(cond), LoopEndList(end), Body(body) {}
	~ForStmtAST() {
		delete InitList;
		delete Cond;
		delete LoopEndList;
		delete Body;
	}
        virtual Value *Codegen();
};

/// ReturnStmtAST - return statement
class ReturnStmtAST : public decafAST {
	decafAST *Val;
public:
	ReturnStmtAST(decafAST *value) : Val(value) {}
	~ReturnStmtAST() {
		if (Val != NULL) { delete Val; }
	}
        virtual Value *Codegen();
};

/// BreakStmtAST - break statement
class BreakStmtAST : public decafAST {
public:
	BreakStmtAST() {}
        virtual Value *Codegen();
};

/// ContinueStmtAST - continue statement
class ContinueStmtAST : public decafAST {
public:
	ContinueStmtAST() {}
        virtual Value *Codegen();
};

/// MethodDeclAST - function definition
class MethodDeclAST : public decafAST {
	decafType ReturnType;
	string Name;
	TypedSymbolListAST *FunctionArgs;
	MethodBlockAST *Block;
public:
	MethodDeclAST(decafType rtype, string name, TypedSymbolListAST *fargs, MethodBlockAST *block)
		: ReturnType(rtype), Name(name), FunctionArgs(fargs), Block(block) {}
	~MethodDeclAST() {
		delete FunctionArgs;
		delete Block;
	}
        virtual Value *Codegen();
};

/// AssignGlobalVarAST - assign value to a global variable
class AssignGlobalVarAST : public decafAST {
	decafType Ty;
	string Name; // location to assign value
	decafAST *Val;
public:
	AssignGlobalVarAST(decafType ty, string name, decafAST *value) : Ty(ty), Name(name), Val(value) {}
	~AssignGlobalVarAST() {
		if (Val != NULL) { delete Val; }
	}
        virtual Value *Codegen();
};

/// FieldDecl - field declaration aka Decaf global variable
class FieldDecl : public decafAST {
	string Name;
	decafType Ty;
	int Size; // -1 for scalars and size value for arrays, size 0 array is an error
public:
	FieldDecl(string name, decafType ty, int size) : Name(name), Ty(ty), Size(size) {}
        virtual Value *Codegen();
};

class FieldDeclListAST : public decafAST {
	list<class decafAST *> arglist;
	decafType listType; // this variable is used if all the symbols in the list share the same type
public:
	FieldDeclListAST() {}
	FieldDeclListAST(string sym, decafType ty, int sz) {
		FieldDecl *s = new FieldDecl(sym, ty, sz);
		arglist.push_front(s);
		listType = ty;
	}
	~FieldDeclListAST() {
		for (list<class decafAST *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
			delete *i;
		}
	}
	void push_front(string sym, decafType ty, int sz) {
		FieldDecl *s = new FieldDecl(sym, ty, sz);
		arglist.push_front(s);
	}
	void push_back(string sym, decafType ty, int sz) {
		FieldDecl *s = new FieldDecl(sym, ty, sz);
		arglist.push_back(s);
	}
	void new_sym(string sym, int sz) {
		if (arglist.empty()) {
			throw runtime_error("Error in AST creation: insertion into empty field list\n");
		}
		FieldDecl *s = new FieldDecl(sym, listType, sz);
		arglist.push_back(s);
	}
        virtual Value *Codegen();
};

class ClassAST : public decafAST {
	string Name;
	FieldDeclListAST *FieldDeclList;
	decafStmtList *MethodDeclList;
public:
	ClassAST(string name, FieldDeclListAST *fieldlist, decafStmtList *methodlist)
		: Name(name), FieldDeclList(fieldlist), MethodDeclList(methodlist) {}
	~ClassAST() {
		if (FieldDeclList != NULL) { delete FieldDeclList; }
		if (MethodDeclList != NULL) { delete MethodDeclList; }
	}
        string getName() {
            return Name;
        }
        virtual Value *Codegen();
};

/// ExternAST - extern function definition
class ExternAST : public decafAST {
	decafType ReturnType;
	string Name;
	TypedSymbolListAST *FunctionArgs;
public:
	ExternAST(decafType r, string n, TypedSymbolListAST *fargs) : ReturnType(r), Name(n), FunctionArgs(fargs) {}
	~ExternAST() {
		if (FunctionArgs != NULL) { delete FunctionArgs; }
	}
        virtual Value *Codegen();
};

/// ProgramAST - the decaf program
class ProgramAST : public decafAST {
	decafStmtList *ExternList;
	ClassAST *ClassDef;
public:
	ProgramAST(decafStmtList *externs, ClassAST *c) : ExternList(externs), ClassDef(c) {}
	~ProgramAST() {
		if (ExternList != NULL) { delete ExternList; }
		if (ClassDef != NULL) { delete ClassDef; }
	}
        virtual Value *Codegen();
};
static std::vector<MethodBlockAST *> MethodBlocks;
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
		prog->Codegen();
        delete prog;
    }

extern_list: extern_list extern_defn
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
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
    { $$ = new FieldDeclListAST(*$2, (decafType)$1, $4); delete $2; }
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

FunctionType *getLlvmFunctionType (std::vector<Type*> args, decafType ty) {
  switch (ty){
    case voidTy: return FunctionType::get(Type::getVoidTy(getGlobalContext()), args, false);
    case intTy: return FunctionType::get(Type::getInt32Ty(getGlobalContext()), args, false);
    case boolTy: return FunctionType::get(Type::getInt1Ty(getGlobalContext()), args, false);
    case stringTy: return FunctionType::get(Type::getInt8PtrTy(getGlobalContext()), args, false);
    default: throw runtime_error("unknown function type");
  }
}

Type *getLlvmType (decafType ty) {
  switch (ty){
    case voidTy: return Builder.getVoidTy();
    case intTy: return Builder.getInt32Ty();
    case boolTy: return Builder.getInt1Ty();
    case stringTy: return Builder.getInt8PtrTy();
    default: throw runtime_error("unknown type");
  }
}
























Value *TypedSymbolListAST::Codegen() {
  for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
    decafType dt = (*i)->getType();
    string ident = (*i)->getIdent();

    Type *llvmTy = getLlvmType(dt);
    alloca = Builder.CreateAlloca(llvmTy, 0, ident);

    // register symbol table
    //syms[ident] = alloca;
    //check
    table->addSymbol(ident, dt, 0, 0, 0, false, alloca);
  }
  return 0;
}

Value *decafStmtList::Codegen() {
  for(list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++){
    (*i)->Codegen();
  }
  return 0;
}

Value *NumberExprAST::Codegen() {
  return ConstantInt::get(getGlobalContext(), APInt(32, Val));
}

Value *StringConstAST::Codegen() {
  // TODO
  const char *s = StringConst.c_str();
  Value *GS = Builder.CreateGlobalString(s, "globalstring");
  return Builder.CreateConstGEP2_32(GS, 0, 0, "cast");
}

Value *BoolExprAST::Codegen() {
  return Val
         ? ConstantInt::get(getGlobalContext(), APInt(1, 1))
         : ConstantInt::get(getGlobalContext(), APInt(1, 0));
}

Value *VariableExprAST::Codegen() {
  description* descriptor = table->getSymbol(Name);
  if(descriptor != NULL) {
  	return Builder.CreateLoad(descriptor->getValue(), Name);
  }
  //return Builder.CreateLoad(syms[Name], Name);
  return NULL;
}

Value *MethodCallAST::Codegen() {
  Function *CalleeF = TheModule->getFunction(Name);
  if (CalleeF == 0) {
    throw runtime_error("could not find the function, " + Name + "\n");
  }
  std::vector <Value*> vars;

  FunctionType *ft = CalleeF->getFunctionType();
  if (ft->getNumParams() != 0) {
      vars = Args->getArgVector();
      unsigned i = 0;
      for (FunctionType::param_iterator pi = ft->param_begin(); pi != ft->param_end(); pi++, i++){
        if (vars[i]->getType()->isIntegerTy(1) && (*pi)->isIntegerTy(32)){
            vars[i] = Builder.CreateZExt(vars[i], Builder.getInt32Ty(), "zexttmp");
        }
      }
  }

  if (vars.size() != CalleeF->arg_size()){
      throw runtime_error("you have more or less number of params");
  } else {
      return Builder.CreateCall(CalleeF, vars);
  }

  return 0;
}

Value *BinaryExprAST::Codegen() {
  Value *L = LHS->Codegen();
  Value *R = RHS->Codegen();
  if (L == 0 | R == 0) return 0;

  switch (Op) {
      case T_PLUS       : return Builder.CreateAdd(L, R, "addtmp");
      case T_MINUS      : return Builder.CreateSub(L, R, "subtmp");
      case T_MULT       : return Builder.CreateMul(L, R, "multmp");
      case T_DIV        : return Builder.CreateSDiv(L, R, "sdivtmp");
      case T_LEFTSHIFT  : return Builder.CreateShl(L, R, "shltmp");
      case T_RIGHTSHIFT : return Builder.CreateLShr(L, R, "lshrtmp");
      case T_MOD        : return Builder.CreateURem(L, R, "uremtmp");
      case T_LT         : return Builder.CreateICmp(CmpInst::ICMP_SLT, L, R, "addtmp");
      case T_GT         : return Builder.CreateICmp(CmpInst::ICMP_SGT, L, R, "addtmp");
      case T_LEQ        : return Builder.CreateICmp(CmpInst::ICMP_SLE, L, R, "addtmp");
      case T_GEQ        : return Builder.CreateICmp(CmpInst::ICMP_SGE, L, R, "addtmp");
      case T_EQ         : return Builder.CreateICmp(CmpInst::ICMP_EQ, L, R, "addtmp");
      case T_NEQ        : return Builder.CreateICmp(CmpInst::ICMP_NE, L, R, "addtmp");
      case T_AND        : return Builder.CreateAnd(L, R, "andtmp");
      case T_OR         : return Builder.CreateOr(L, R, "ortmp");
      default: throw runtime_error("unknown type in BinaryOpString call");
  }
}

Value *UnaryExprAST::Codegen() {
  Value *E = Expr->Codegen();
  if (E == 0) return 0;

  switch (Op) {
      case T_MINUS      : return Builder.CreateNeg(E, "negtmp");
      case T_NOT        : return Builder.CreateNot(E, "nottmp");
      default: throw runtime_error("unknown type in BinaryOpString call");
  }
}

Value *AssignVarAST::Codegen() {
  description* descriptor = table->getSymbol(Name);
  if(descriptor != NULL) {
  	Builder.CreateStore(Val->Codegen(), descriptor->getValue(), false);
  }
  //Builder.CreateStore(Val->Codegen(), syms[Name], false);
  return 0;
}

Value *AssignArrayLocAST::Codegen() {
  return 0;
}

Value *ArrayLocExprAST::Codegen() {
  return 0;
}

Value *BlockAST::Codegen() {
  table->addTable();

  // codegen
  Vars->Codegen();
  Statements->Codegen();

  // TODO erase the block in symbol tabl
  table->removeTable();
  return 0;
}

Value *MethodBlockAST::Codegen() {
  Builder.SetInsertPoint(BB);
  // codegen
  Vars->Codegen();
  Statements->Codegen();

  switch (DT){
      case voidTy: return Builder.CreateRetVoid();
      case intTy: return Builder.CreateRet(ConstantInt::get(getGlobalContext(), APInt(32, 0)));
      case boolTy: return Builder.CreateRet(ConstantInt::get(getGlobalContext(), APInt(1, 0)));
      default: throw runtime_error("Unknown return type");
  }
  return 0;
}

Value *IfStmtAST::Codegen() {
  return 0;
}

Value *WhileStmtAST::Codegen() {
  return 0;
}

Value *ForStmtAST::Codegen() {
  return 0;
}

Value *ReturnStmtAST::Codegen() {
  return 0;
}

Value *BreakStmtAST::Codegen() {
  return 0;
}

Value *ContinueStmtAST::Codegen() {
  return 0;
}

Value *MethodDeclAST::Codegen() {

  table->addTable();
  // initialize args in the method
  std::vector<Type*> args;
  if (FunctionArgs != NULL) {
    args = FunctionArgs->getTypesOfArgs();
  }

  // generate the function
  FunctionType *type = getLlvmFunctionType(args, ReturnType);
  Function *function = Function::Create(type , Function::ExternalLinkage, Name, TheModule);

  // create block
  BasicBlock *BB = BasicBlock::Create(getGlobalContext(), "entry", function);

  // set names for all arguments
  if (FunctionArgs != NULL) {
    Builder.SetInsertPoint(BB);
    unsigned Idx = 0;
    std::vector<TypedSymbol *> ts = FunctionArgs->getArgsList();
    for (Function::arg_iterator AI = function->arg_begin(); Idx != FunctionArgs->size(); ++AI, ++Idx) {
      string id = ts[Idx]->getIdent();
      decafType dt = ts[Idx]->getType();
      AI->setName(id);

      Type *llvmTy = getLlvmType(dt);
      AllocaInst *Alloca = Builder.CreateAlloca(llvmTy, 0, id);
      Builder.CreateStore(AI, Alloca);
      table->addSymbol(id, dt, 0, 0, 0, false, Alloca);
      //syms[id] = Alloca;
    }
  }

  Block->setBasicBlock(BB);
  Block->setReturnType(ReturnType);
  MethodBlocks.push_back(Block);

  return 0;
}

Value *AssignGlobalVarAST::Codegen() {
  return 0;
}

Value *FieldDecl::Codegen() {
  return 0;
}

Value *FieldDeclListAST::Codegen() {
  return 0;
}

Value *ClassAST::Codegen() {
  Value *md = MethodDeclList->Codegen();
  for (int i = 0; i < MethodBlocks.size(); i ++){
    MethodBlocks[i]->Codegen();
  }
  return md;
}

Value *ExternAST::Codegen() {
  // initialize args in extern function
  std::vector<Type*> args;
  if (FunctionArgs != NULL) {
    args = FunctionArgs->getTypesOfArgs();
  }

  // get function type and generate the function with the type
  FunctionType *type = getLlvmFunctionType(args, ReturnType);
  Function *function = Function::Create(type , Function::ExternalLinkage, Name, TheModule);

  return function;
}

Value *ProgramAST::Codegen() {
  // generate a new module
  LLVMContext &Context = getGlobalContext();
  TheModule = new Module(ClassDef->getName(), Context);

  // start code generation
  ExternList->Codegen();
  ClassDef->Codegen();
  return 0;
}

int main() {
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  // Print out all of the generated code to stderr
  TheModule->dump();
  return(retval >= 1 ? 1 : 0);
}
