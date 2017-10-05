
#include "decafdefs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
#include "expr-codegen.tab.h"
#endif

using namespace std;

typedef enum { voidTy, intTy, boolTy, stringTy, } decafType;

string TyString(decafType x) {
	switch (x) {
		case voidTy: return string("VoidType");
		case intTy: return string("IntType");
		case boolTy: return string("BoolType");
		case stringTy: return string("StringType");
		default: throw runtime_error("unknown type in TyString call");
	}
}

string BinaryOpString(int Op) {
	switch (Op) {
		case T_PLUS: return string("Plus");
  		case T_MINUS: return string("Minus");
  		case T_MULT: return string("Mult");
  		case T_DIV: return string("Div");
  		case T_LEFTSHIFT: return string("Leftshift");
  		case T_RIGHTSHIFT: return string("Rightshift");
  		case T_MOD: return string("Mod");
  		case T_LT: return string("Lt");
  		case T_GT: return string("Gt");
  		case T_LEQ: return string("Leq");
  		case T_GEQ: return string("Geq");
  		case T_EQ: return string("Eq");
  		case T_NEQ: return string("Neq");
  		case T_AND: return string("And");
  		case T_OR: return string("Or");
		default: throw runtime_error("unknown type in BinaryOpString call");
	}
}

string UnaryOpString(int Op) {
	switch (Op) {
  		case T_MINUS: return string("UnaryMinus");
  		case T_NOT: return string("Not");
		default: throw runtime_error("unknown type in UnaryOpString call");
	}
}

string convertInt(int number) {
	stringstream ss;
	ss << number;
	return ss.str();
}

/// decafAST - Base class for all abstract syntax tree nodes.
class decafAST {
public:
  virtual ~decafAST() {}
  virtual string str() { return string(""); }
  virtual llvm::Value *Codegen() = 0;
};

string getString(decafAST *d) {
	if (d != NULL) {
		return d->str();
	} else {
		return string("None");
	}
}

string buildString1(const char *Name, decafAST *a) {
	return string(Name) + "(" + getString(a) + ")";
}

string buildString1(const char *Name, string a) {
	return string(Name) + "(" + a + ")";
}

string buildString2(const char *Name, decafAST *a, decafAST *b) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + ")";
}

string buildString2(const char *Name, string a, decafAST *b) {
	return string(Name) + "(" + a + "," + getString(b) + ")";
}

string buildString2(const char *Name, string a, string b) {
	return string(Name) + "(" + a + "," + b + ")";
}

string buildString3(const char *Name, decafAST *a, decafAST *b, decafAST *c) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, decafAST *b, decafAST *c) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, string b, decafAST *c) {
	return string(Name) + "(" + a + "," + b + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, string b, string c) {
	return string(Name) + "(" + a + "," + b + "," + c + ")";
}

string buildString4(const char *Name, string a, decafAST *b, decafAST *c, decafAST *d) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + "," + getString(d) + ")";
}

string buildString4(const char *Name, decafAST *a, decafAST *b, decafAST *c, decafAST *d) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + "," + getString(d) + ")";
}

template <class T>
string commaList(list<T> vec) {
	string s("");
	for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) {
		s = s + (s.empty() ? string("") : string(",")) + (*i)->str();
	}
	if (s.empty()) {
		s = string("None");
	} else {
   		s = string("[") + s + string("]");
	}
	return s;
}

class TypedSymbol {
	string Sym;
	decafType Ty;
public:
	TypedSymbol(string s, decafType t) : Sym(s), Ty(t) {}
	string str() { return Sym + ":" + TyString(Ty); }
	virtual llvm::Type *getType();
	virtual string getName();
};

class TypedSymbolListAST : public decafAST {
	list<class TypedSymbol *> arglist;
	decafType listType; // this variable is used if all the symbols in the list share the same type
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
	string str() { return commaList<class TypedSymbol *>(arglist); }
	virtual void typedArgList(std::vector<llvm::Type *> &);
	virtual void setArgNames(llvm::Function *);
	virtual llvm::Value *Codegen();
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
	string str() { return commaList<class decafAST *>(stmts); }
	virtual llvm::Value *insertDeclares();
	virtual llvm::Value *Codegen();
	virtual void listCodegenVec(std::vector<llvm::Value *> &val);
};

/// NumberExprAST - Expression class for integer numeric literals like "12".
class NumberExprAST : public decafAST {
	int Val;
public:
	NumberExprAST(int val) : Val(val) {}
	string str() { return buildString1("Number", convertInt(Val)); }
	virtual llvm::Value *Codegen();
};

/// StringConstAST - string constant
class StringConstAST : public decafAST {
	string StringConst;
public:
	StringConstAST(string s) : StringConst(s) {}
	string str() { return buildString1("StringConstant", StringConst); }
	virtual llvm::Value *Codegen();
};

/// BoolExprAST - Expression class for boolean literals: "true" and "false".
class BoolExprAST : public decafAST {
	bool Val;
public:
	BoolExprAST(bool val) : Val(val) {}
	string str() { return buildString1("Bool", Val ? string("True") : string("False")); }
	virtual llvm::Value *Codegen();
};

/// VariableExprAST - Expression class for variables like "a".
class VariableExprAST : public decafAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
	string str() { return buildString1("Var", Name); }
	//const std::string &getName() const { return Name; }
	virtual llvm::Value *Codegen();
};

/// MethodCallAST - call a function with some arguments
class MethodCallAST : public decafAST {
	string Name;
	decafStmtList *Args;
public:
	MethodCallAST(string name, decafStmtList *args) : Name(name), Args(args) {}
	~MethodCallAST() { delete Args; }
	string str() { return buildString2("MethodCall", Name, Args); }
	virtual llvm::Value *Codegen();
};

/// BinaryExprAST - Expression class for a binary operator.
class BinaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *LHS, *RHS;
public:
	BinaryExprAST(int op, decafAST *lhs, decafAST *rhs) : Op(op), LHS(lhs), RHS(rhs) {}
	~BinaryExprAST() { delete LHS; delete RHS; }
	string str() { return buildString3("BinaryOp", BinaryOpString(Op), LHS, RHS); }
	virtual llvm::Value *Codegen();
};

/// UnaryExprAST - Expression class for a unary operator.
class UnaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *Expr;
public:
	UnaryExprAST(int op, decafAST *expr) : Op(op), Expr(expr) {}
	~UnaryExprAST() { delete Expr; }
	string str() { return buildString2("UnaryOp", UnaryOpString(Op), Expr); }
	virtual llvm::Value *Codegen();
};

/// AssignVarAST - assign value to a variable
class AssignVarAST : public decafAST {
	string Name; // location to assign value
	decafAST *Value;
public:
	AssignVarAST(string name, decafAST *value) : Name(name), Value(value) {}
	~AssignVarAST() {
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString2("AssignVariable", Name, Value); }
	virtual llvm::Value *Codegen();
};

/// AssignArrayLocAST - assign value to a variable
class AssignArrayLocAST : public decafAST {
	string Name; // name of array variable
        decafAST *Index;  // index for assignment of value
	decafAST *Value;
public:
	AssignArrayLocAST(string name, decafAST *index, decafAST *value) : Name(name), Index(index), Value(value) {}
	~AssignArrayLocAST() { delete Index; delete Value; }
	string str() { return buildString3("AssignToArrayLocation", Name, Index, Value); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString2("ArrayLocation", Name, Expr); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString2("Block", Vars, Statements); }
	virtual llvm::Value *Codegen();
};

/// MethodBlockAST - block for methods
class MethodBlockAST : public decafAST {
	decafStmtList *Vars;
	decafStmtList *Statements;
public:
	MethodBlockAST(decafStmtList *vars, decafStmtList *s) : Vars(vars), Statements(s) {}
	~MethodBlockAST() {
		if (Vars != NULL) { delete Vars; }
		if (Statements != NULL) { delete Statements; }
	}
	string str() { return buildString2("MethodBlock", Vars, Statements); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString3("If", Cond, IfTrueBlock, ElseBlock); }
	virtual llvm::Value *Codegen();
};

/// WhileStmtAST - while statement
class WhileStmtAST : public decafAST {
	decafAST *Cond;
	BlockAST *Body;
public:
	WhileStmtAST(decafAST *cond, BlockAST *body) : Cond(cond), Body(body) {}
	~WhileStmtAST() { delete Cond; delete Body; }
	string str() { return buildString2("While", Cond, Body); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString4("For", InitList, Cond, LoopEndList, Body); }
	virtual llvm::Value *Codegen();
};

/// ReturnStmtAST - return statement
class ReturnStmtAST : public decafAST {
	decafAST *Value;
public:
	ReturnStmtAST(decafAST *value) : Value(value) {}
	~ReturnStmtAST() {
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString1("Return", Value); }
	virtual llvm::Value *Codegen();
};

/// BreakStmtAST - break statement
class BreakStmtAST : public decafAST {
public:
	BreakStmtAST() {}
	string str() { return string("Break"); }
	virtual llvm::Value *Codegen();
};

/// ContinueStmtAST - continue statement
class ContinueStmtAST : public decafAST {
public:
	ContinueStmtAST() {}
	string str() { return string("Continue"); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString3("MethodDeclaration", Name, FunctionArgs, Block); }
	virtual llvm::Function *proto();
	virtual llvm::Value *Codegen();
};

/// AssignGlobalVarAST - assign value to a global variable
class AssignGlobalVarAST : public decafAST {
	decafType Ty;
	string Name; // location to assign value
	decafAST *Value;
public:
	AssignGlobalVarAST(decafType ty, string name, decafAST *value) : Ty(ty), Name(name), Value(value) {}
	~AssignGlobalVarAST() {
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString3("AssignGlobalVariable", TyString(Ty), Name, Value); }
	virtual llvm::Value *Codegen();
};

/// FieldDecl - field declaration aka Decaf global variable
class FieldDecl : public decafAST {
	string Name;
	decafType Ty;
	int Size; // -1 for scalars and size value for arrays, size 0 array is an error
public:
	FieldDecl(string name, decafType ty, int size) : Name(name), Ty(ty), Size(size) {}
	string str() { return buildString3("FieldDeclaration", Name, TyString(Ty), convertInt(Size)); }
	virtual llvm::Value *Codegen();
	virtual llvm::Type *getType();
	virtual llvm::Type *getArrayType();
	virtual string getName();
	virtual int getSize();
};

class FieldDeclListAST : public decafAST {
	list<class FieldDecl *> arglist;
	decafType listType; // this variable is used if all the symbols in the list share the same type
public:
	FieldDeclListAST() {}
	FieldDeclListAST(string sym, decafType ty, int sz) {
		FieldDecl *s = new FieldDecl(sym, ty, sz);
		arglist.push_front(s);
		listType = ty;
	}
	~FieldDeclListAST() {
		for (list<class FieldDecl *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
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
	string str() { return commaList<class FieldDecl *>(arglist); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString3("Class", Name, FieldDeclList, MethodDeclList); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString3("ExternFunction", Name, TyString(ReturnType), FunctionArgs); }
	virtual llvm::Value *Codegen();
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
	string str() { return buildString2("Program", ExternList, ClassDef); }
	virtual llvm::Value *Codegen();
};

