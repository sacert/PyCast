
#include "decaf-defs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
#include "decaf-ast.tab.h"
#endif

using namespace std;

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
		default: throw runtime_error("unknown type in BinaryOpString call");
	}
}

string TypeString(int type){
	switch(type) {
		case T_INTTYPE: return string("IntType");
		case T_BOOLTYPE: return string("BoolType");
		case T_VOIDTYPE: return string("VoidType");
		case T_STRINGTYPE: return string("StringType");
		default: throw runtime_error("unknown type in TypeString call");
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

string buildString3(const char *Name, decafAST *a, decafAST *b, decafAST *c) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, decafAST *b, decafAST *c) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + ")";
}

string buildString4(const char *Name, decafAST *a, decafAST *b, decafAST *c, decafAST *d) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + "," + getString(d) + ")";
}

string buildString4(const char *Name, string a, decafAST *b, decafAST *c, decafAST *d) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + "," + getString(d) + ")";
}


template <class T>
string commaList(list<T> vec) {
	string s("");
	for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) {
		s = s + (s.empty() ? string("") : string(",")) + (*i)->str();
	}
	if (s.empty()) {
		s = string("None");
	}
	return s;
}

/// decafStmtList - List of Decaf statements
class decafStmtList : public decafAST {
public:
	list<decafAST *> stmts;
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
};

/// commaStmtAST
class commaStmtAST {
	list<string *> stmts;
public:
	commaStmtAST() {}
	~commaStmtAST() {
		for (list<string *>::iterator i = stmts.begin(); i != stmts.end(); i++) {
			delete *i;
		}
	}
	int size() { return stmts.size(); }
	void push_front(string *e) { stmts.push_front(e); }
	void push_back(string *e) { stmts.push_back(e); }
};























class IDAST : public decafAST {
	string Name;
public:
	IDAST(string name) : Name(name) {}
	string str() { return Name; }
};

/// UnaryExpr(unary_operator op, expr value)
/// UnaryExprAST
class UnaryExprAST : public decafAST {
	int Op;
	decafAST *Value;
public:
	UnaryExprAST(int op, decafAST *value) : Op(op), Value(value) {}
	~UnaryExprAST() { delete Value; }
	string str() { return buildString2("UnaryExpr", UnaryOpString(Op), Value); }
};

/// BinaryExpr(binary_operator op, expr left_value, expr right_value)
/// BinaryExprAST
class BinaryExprAST : public decafAST {
	int Op;
	decafAST *LeftValue;
	decafAST *RightValue;
public:
	BinaryExprAST(int op, decafAST *leftValue, decafAST *rightValue) : Op(op), LeftValue(leftValue), RightValue(rightValue) {}
	~BinaryExprAST() { delete LeftValue; delete RightValue; }
	string str() { return buildString3("BinaryExpr", BinaryOpString(Op), LeftValue, RightValue); }
};

/// BoolExpr(bool value)
/// BoolExprAST
class BoolExprAST : public decafAST {
	bool Value;
public:
	BoolExprAST(bool value) : Value(value) {}
	string str() { return buildString1( "BoolExpr", Value ? string("True") : string("False") ); }
};

/// NumberExpr(int value)
/// NumberExprAST
class NumberExprAST : public decafAST {
	int Value;
public:
	NumberExprAST(int value) : Value(value) {}
	string str() { return buildString1( "Number", convertInt(Value) ); }
};

/// ArrayLocExpr(identifier name, expr index, expr value)
/// ArrayLocExprAST
class ArrayLocExprAST : public decafAST {
	string Name;
	decafAST *Index;
	decafAST *Value;
public:
	ArrayLocExprAST(string name, decafAST *index, decafAST *value) : Name(name), Index(index), Value(value) {}
	~ArrayLocExprAST() {
		if (Index != NULL) { delete Index; }
		if (Value != NULL) { delete Value; }
	}
	string str() { if (Value == NULL) { return buildString2( "ArrayLocExpr", Name, Index ); } return buildString3( "ArrayLocExpr", Name, Index, Value ); }
};


/// VariableExpr(identifier name)
/// VariableExprAST
class VariableExprAST : public decafAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
	string str() { return buildString1( "VariableExpr", Name ); }
};

/// StringConstant(string value)
/// StringConstantAST
class StringConstantAST : public decafAST {
	string Value;
public:
	StringConstantAST(string value) : Value(value) {}
	string str() {
            Value = "\"" + Value + "\"";
            return buildString1( "StringConstant", Value );
        }
};

/// ContinueStmt
/// ContinueStmtAST
class ContinueStmtAST : public decafAST {
public:
	ContinueStmtAST() {}
	string str() { return "ContinueStmt"; }
};

/// BreakStmt
/// BreakStmtAST
class BreakStmtAST : public decafAST {
public:
	BreakStmtAST() {}
	string str() { return "BreakStmt"; }
};

/// ReturnStmt(expr? return_value)
/// ReturnStmtAST
class ReturnStmtAST : public decafAST {
	decafAST *ReturnValue;
public:
	ReturnStmtAST(decafAST *returnValue) : ReturnValue(returnValue) {}
	~ReturnStmtAST() {
		if (ReturnValue != NULL) { delete ReturnValue; }
	}
	string str() { return buildString1("ReturnStmt", ReturnValue); }
};


/// ForStmt(assign* pre_assign_list, expr condition, assign* loop_assign_list)
/// ForStmtAST
class ForStmtAST : public decafAST {
	decafStmtList *PreAssignList;
	decafAST *Condition;
	decafStmtList *LoopAssignList;
	decafAST *Block;
public:
	ForStmtAST(decafStmtList *preAssignList, decafAST *condition, decafStmtList *loopAssignList, decafAST *block) : PreAssignList(preAssignList), Condition(condition), LoopAssignList(loopAssignList), Block(block) {}
	~ForStmtAST() {
		if (PreAssignList != NULL) { delete PreAssignList; }
		if (Condition != NULL) { delete Condition; }
		if (LoopAssignList != NULL) { delete LoopAssignList; }
		if (Block != NULL) { delete Block; }
	}
	string str() { return buildString4("ForStmt", PreAssignList, Condition, LoopAssignList, Block); }
};


/// WhileStmt(expr condition, block while_block)
/// WhileStmtAST
class WhileStmtAST : public decafAST {
	decafAST *Condition;
	decafAST *WhileBlock;
public:
	WhileStmtAST(decafAST *condition, decafAST *whileBlock) : Condition(condition), WhileBlock(whileBlock) {}
	~WhileStmtAST() {
		if (Condition != NULL) { delete Condition; }
		if (WhileBlock != NULL) { delete WhileBlock; }
	}
	string str() { return buildString2("WhileStmt", Condition, WhileBlock); }
};


/// IfStmt(expr condition, block if_block, block? else_block)
/// IfStmtAST
class IfStmtAST : public decafAST {
	decafAST *Condition;
	decafAST *IfBlock;
	decafAST *ElseBlock;
public:
	IfStmtAST(decafAST *condition, decafAST *ifBlock, decafAST *elseBlock) : Condition(condition), IfBlock(ifBlock), ElseBlock(elseBlock) {}
	~IfStmtAST() {
		if (Condition != NULL) { delete Condition; }
		if (IfBlock != NULL) { delete IfBlock; }
		if (ElseBlock != NULL) { delete ElseBlock; }
	}
	string str() { return buildString3("IfStmt", Condition, IfBlock, ElseBlock); }
};


/// MethodCall(identifier name, method_arg* method_arg_list)
/// MethodCallAST
class MethodCallAST : public decafAST {
	string Name;
	decafStmtList *MethodArgList;
public:
	MethodCallAST(string name, decafStmtList *methodArgList) : Name(name), MethodArgList(methodArgList) {}
	~MethodCallAST() {
		if (MethodArgList != NULL) { delete MethodArgList; }
	}
	string str() { return buildString2("MethodCall", Name, MethodArgList); }
};

/// AssignArrayLoc(identifier name, expr index, expr value)
/// AssignArrayLocAST
class AssignArrayLocAST : public decafAST {
	string Name;
	decafAST *Index;
	decafAST *Value;
public:
	AssignArrayLocAST(string name, decafAST *index, decafAST *value) : Name(name), Index(index), Value(value) {}
	~AssignArrayLocAST() {
		if (Index != NULL) { delete Index; }
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString3("AssignArrayLoc", Name, Index, Value); }
};


/// AssignVar(identifier name, expr value)
/// AssignVarAST
class AssignVarAST : public decafAST {
	string Name;
	decafAST *Value;
public:
	AssignVarAST(string name, decafAST *value) : Name(name), Value(value) {}
	~AssignVarAST() {
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString2("AssignVar", Name, Value); }
};


/// block = Block(typed_symbol*, statement*)
/// BlockAST
class BlockAST : public decafAST {
	decafStmtList *VarDeclList;
	decafStmtList *StatementList;
public:
	BlockAST(decafStmtList *varDeclList, decafStmtList *statementList) : VarDeclList(varDeclList), StatementList(statementList) {}
	~BlockAST() {
		if (VarDeclList != NULL) { delete VarDeclList; }
		if (StatementList != NULL) { delete StatementList; }
	}
	string str() { return buildString2("Block", VarDeclList, StatementList); }
};

/// method_block = MethodBlock(typed_symbol*, statement*)
/// MethodBlockAST
class MethodBlockAST : public decafAST {
	decafStmtList *VarDeclList;
	decafStmtList *StatementList;
public:
	MethodBlockAST(decafStmtList *varDeclList, decafStmtList *statementList) : VarDeclList(varDeclList), StatementList(statementList) {}
	~MethodBlockAST() {
		if (VarDeclList != NULL) { delete VarDeclList; }
		if (StatementList != NULL) { delete StatementList; }
	}
	string str() { return buildString2("MethodBlock", VarDeclList, StatementList); }
};


/// typed_symbol = VarDef(identifier, decaf_type)
/// TypedSymbolAST
class TypedSymbolAST : public decafAST {
	string Name;
	decafAST *Type;
public:
	TypedSymbolAST(string name, decafAST *type) : Name(name), Type(type) {}
	~TypedSymbolAST() {
		if (Type != NULL) { delete Type; }
	}
	string str() { if(Name == ""){ return buildString1( "VarDef", Type); } return buildString2("VarDef", Name, Type); }
};

/// MethodDeclAST
class MethodDeclAST : public decafAST {
	string Name;
	decafAST *ReturnType;
	decafStmtList *ParamList;
	decafAST *Block;
public:
	MethodDeclAST(string name, decafAST *returnType, decafStmtList *paramList, decafAST *block) : Name(name), ReturnType(returnType), ParamList(paramList), Block(block) {}
	~MethodDeclAST() {
		if (ReturnType != NULL) { delete ReturnType; }
		if (ParamList != NULL) { delete ParamList; }
		if (Block != NULL) { delete Block; }
	}
	string str() { return buildString4("Method", Name, ReturnType, ParamList, Block); }
};

/// FieldSizeAST
class FieldSizeAST : public decafAST {
	int ArraySize;
public:
	FieldSizeAST(int arraySize) : ArraySize(arraySize) {}
	~FieldSizeAST() {}
	string str() { if (ArraySize == -1) { return "Scalar"; } return buildString1("Array", convertInt(ArraySize)); }
};

/// AssignGlobalVarAST
class AssignGlobalVarAST : public decafAST {
	string Name;
	decafAST *Type;
	decafAST *Value;
public:
	AssignGlobalVarAST(string name, decafAST *type, decafAST *value) : Name(name), Type(type), Value(value) {}
	~AssignGlobalVarAST() {
		if (Type != NULL) { delete Type; }
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString3("AssignGlobalVar", Name, Type, Value); }
};

/// FieldDeclAST
class FieldDeclAST : public decafAST {
	string Name;
	decafAST *Type;
	decafAST *SizeType;
public:
	FieldDeclAST(string name, decafAST *type, decafAST *sizeType) : Name(name), Type(type), SizeType(sizeType) {}
	~FieldDeclAST() {
		if (Type != NULL) { delete Type; }
		if (SizeType != NULL) { delete SizeType; }
	}
	string str() { return buildString3("FieldDecl", Name, Type, SizeType); }
};

class TypeAST : public decafAST {
	int TypeID;
public:
	TypeAST(int typeId) : TypeID(typeId) {}
	string str() { return TypeString(TypeID); }
};

/// ExternAST
class ExternAST : public decafAST {
	string Name;
	decafAST *MethodType;
	decafStmtList *TypeList;
public:
	ExternAST(string name, decafAST *methodType, decafStmtList *typeList) : Name(name), MethodType(methodType), TypeList(typeList) {}
	~ExternAST() {
		if (MethodType != NULL) { delete MethodType; }
		if (TypeList != NULL) { delete TypeList; }
	}
	string str() { return buildString3("ExternFunction", Name, MethodType, TypeList); }
};

/// ClassAST
class ClassAST : public decafAST {
	string Name;
	decafStmtList *FieldList;
	decafStmtList *MethodList;
public:
	ClassAST(string name, decafStmtList *fieldList, decafStmtList *methodList) : Name(name), FieldList(fieldList), MethodList(methodList) {}
	~ClassAST() {
		if (FieldList != NULL) { delete FieldList; }
		if (MethodList != NULL) { delete MethodList; }
	}
	string str() { return buildString3("Class", Name, FieldList, MethodList); }
};

/// ProgramAST - the simplified decaf program
class ProgramAST : public decafAST {
	decafStmtList *ExternList;
	decafAST *Body;
public:
	ProgramAST(decafStmtList *externs, decafAST *body) : ExternList(externs), Body(body) {}
	~ProgramAST() {
		if (ExternList != NULL) { delete ExternList; }
		if (Body != NULL) { delete Body; }
	}
	string str() { return buildString2("Program", ExternList, Body); }
};

