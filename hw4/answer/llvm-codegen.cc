#include "decafdefs.h"
#include <list>

static std::list<llvm::BasicBlock *> continueBlocks;
static std::list<llvm::BasicBlock *> endBlocks;

template <class T>
llvm::Value *listCodegen(list<T> vec) {
	llvm::Value *val = NULL;
	for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) {
		llvm::Value *j = (*i)->Codegen();
		if (j != NULL) { val = j; }
	}
	return val;
}

void decafStmtList::listCodegenVec(std::vector<llvm::Value *> &val) {
	for (list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) {
		llvm::Value *argval = (*i)->Codegen();
		if (NULL == argval) {
			throw runtime_error("invalid argument in method call");
		}
		val.push_back(argval);
	}
}

llvm::Type *getLLVMType(decafType ty) {
	switch (ty) {
		case voidTy: return Builder.getVoidTy();
		case intTy: return Builder.getInt32Ty();
		case boolTy: return Builder.getInt1Ty();
		case stringTy: return Builder.getInt8PtrTy();
		default: throw runtime_error("unknown type in getType call");
	}
}

llvm::Type *getLLVMArrayType(decafType ty, int size) {
        llvm::ArrayType *at = llvm::ArrayType::get(getLLVMType(ty), size);
        return at;
}

llvm::Constant *getZeroInit(decafType ty) {
	switch (ty) {
		case intTy: return Builder.getInt32(0);
		case boolTy: return Builder.getInt1(0);
		default: throw runtime_error("unknown type in getZeroInit call");
	}
}

llvm::Type *FieldDecl::getType() {
	return getLLVMType(Ty);
}

llvm::Type *FieldDecl::getArrayType() {
	return getLLVMArrayType(Ty, Size);
}

std::string FieldDecl::getName() {
	return Name;
}

int FieldDecl::getSize() {
	return Size;
}

llvm::Type *TypedSymbol::getType() {
	return getLLVMType(Ty);
}

std::string TypedSymbol::getName() {
	return Sym;
}

void TypedSymbolListAST::typedArgList(std::vector<llvm::Type *> &args) {
	for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
		args.push_back((*i)->getType());
	}
}

void TypedSymbolListAST::setArgNames(llvm::Function *func) {
	if (NULL == func) {
		throw runtime_error("no function found");
	}
	llvm::Function::arg_iterator AI = func->arg_begin();
	for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end() && AI != func->arg_end(); i++, AI++) {
		if (NULL == AI) {
			throw runtime_error("could not find arg in function arglist");
		}
		string name = (*i)->getName();
		AI->setName(name);
		llvm::AllocaInst *Alloca = Builder.CreateAlloca((*i)->getType(), 0, name.c_str());
	    // Store the initial value into the alloca.
    	Builder.CreateStore(AI, Alloca);
	    // Add to symbol table
	    syms.enter_symtbl(name, Alloca);
	}
}

llvm::Value *decafStmtList::Codegen() {
	return listCodegen<decafAST *>(stmts);
}

llvm::AllocaInst *defineVariable(llvm::Type *llvmTy, string ident) {
	llvm::AllocaInst *Alloca = Builder.CreateAlloca(llvmTy, 0, ident.c_str());
	syms.enter_symtbl(ident, Alloca);
	return Alloca;
}

llvm::GlobalVariable *defineGlobalVariableNoInitVal(llvm::Type *llvmTy, string ident) {
        llvm::Constant *zeroInit = llvm::Constant::getNullValue(llvmTy);
        llvm::GlobalVariable *gv = new llvm::GlobalVariable(*TheModule, llvmTy, false, llvm::GlobalValue::InternalLinkage, zeroInit, ident.c_str());
        syms.enter_symtbl(ident, gv);
	return gv;
}

llvm::Value *TypedSymbolListAST::Codegen() {
	llvm::Value *val = NULL;
	for (list<class TypedSymbol *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
		val = defineVariable((*i)->getType(), (*i)->getName());
	}
	return val;
}

llvm::Function *insertDeclare(decafType ReturnType, string Name, TypedSymbolListAST *FunctionArgs) {
	llvm::Type *returnTy = getLLVMType(ReturnType);
	std::vector<llvm::Type *> args;
	if (NULL != FunctionArgs) {
		FunctionArgs->typedArgList(args); // fill up the args vector with types
	}
	llvm::Function *func = llvm::Function::Create(
		llvm::FunctionType::get(returnTy, args, false),
		llvm::Function::ExternalLinkage,
		Name,
		TheModule
	);
	if (NULL == func) {
		throw runtime_error("problem defining method " + Name);
	}
	syms.enter_symtbl(Name, func);
	return func;
}

llvm::Function *MethodDeclAST::proto() {
	return insertDeclare(ReturnType, Name, FunctionArgs);
}

llvm::Value *decafStmtList::insertDeclares() {
	llvm::Value *val = NULL;
	string main("main");
	bool hasMain = false;
	for (list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) {
		MethodDeclAST *m = (MethodDeclAST *)(*i);
		val = m->proto();
        if (NULL == val) {
	        throw runtime_error("no prototype found for function");
	    }
		if (val->getName() == main) {
			hasMain = true;
		}
	}
	if (! hasMain) {
		throw runtime_error("decaf programs must have a main method");
	}
	return val;
}

llvm::Value *NumberExprAST::Codegen() {
	return Builder.getInt32(Val);
}

llvm::Value *StringConstAST::Codegen() {
	const char *s = StringConst.c_str();
	llvm::Value *GS = Builder.CreateGlobalString(s, "globalstring");
	return Builder.CreateConstGEP2_32(GS, 0, 0, "cast");
}

llvm::Value *BoolExprAST::Codegen() {
	return Builder.getInt1(Val);
}

llvm::Value *VariableExprAST::Codegen() {
	llvm::Value *V = syms.access_symtbl(Name);
	if (V == NULL) throw runtime_error("could not find variable: " + Name);
	return Builder.CreateLoad(V, Name.c_str());
}

llvm::Value *MethodCallAST::Codegen() {
	std::vector<llvm::Value *> argvals;
	if (Args != NULL) {
		Args->listCodegenVec(argvals);
	}
	llvm::Function *call = (llvm::Function *)syms.access_symtbl(Name);
	if (NULL == call) {
		throw runtime_error("unknown method " + Name);
	}
	if (call->arg_size() != argvals.size()) {
		throw runtime_error("incorrect number of arguments for " + Name);
	}

	// check types and promote i1 to i32 if needed
	std::vector<llvm::Value *> finalargs;
	llvm::Function::arg_iterator AI = call->arg_begin();
	for (std::vector<llvm::Value *>::iterator i = argvals.begin(); i != argvals.end() && AI != call->arg_end(); i++, AI++) {
		if (AI->getType() == (*i)->getType()) {
			finalargs.push_back(*i);
		}
		if (AI->getType()->isIntegerTy(32) && (*i)->getType()->isIntegerTy(1)) {
			llvm::Value *promo = Builder.CreateZExt(*i, Builder.getInt32Ty(), "zexttmp");
			finalargs.push_back(promo);
		} else {
			if (AI->getType() != (*i)->getType()) {
				throw runtime_error("type mismatch in method call " + Name);
			}
		}
	}
	bool isVoid = call->getReturnType()->isVoidTy();
	llvm::Value *val = Builder.CreateCall(
		call,
		finalargs,
		isVoid ? "" : "calltmp"
	);
	return isVoid ? NULL : val;
}

llvm::Value *ShortCircuit(int Op, decafAST *LHS, decafAST *RHS) {
	throw runtime_error("shortcircuit not implemented");
}

llvm::Value *BinaryExprAST::Codegen() {
	if (shortcircuit && ((Op == T_AND) || (Op == T_OR))) {
		return ShortCircuit(Op, LHS, RHS);
	}
	llvm::Value *L = LHS->Codegen();
	llvm::Value *R = RHS->Codegen();
	if ((L == NULL) || (R == NULL)) {
		throw runtime_error("invalid binary expression");
	}
	// type checking
	switch (Op) {
		case T_PLUS:
		case T_MINUS:
		case T_MULT:
		case T_DIV:
		case T_LEFTSHIFT:
		case T_RIGHTSHIFT:
		case T_MOD:
		case T_LT:
		case T_GT:
		case T_LEQ:
		case T_GEQ:
			if (! (L->getType()->isIntegerTy(32) && R->getType()->isIntegerTy(32))) {
				throw runtime_error("type mismatch in integer expression");
			}
			break;
		case T_AND:
		case T_OR:
			if (! (L->getType()->isIntegerTy(1) && R->getType()->isIntegerTy(1))) {
				throw runtime_error("type mismatch in boolean expression");
			}
			break;
		case T_EQ:
		case T_NEQ:
			if (L->getType() != R->getType()) {
				throw runtime_error("type mismatch in comparison expression");
			}
			break;
	}

	// code generation
	switch (Op) {
		case T_PLUS: return Builder.CreateAdd(L, R, "addtmp");
		case T_MINUS: return Builder.CreateSub(L, R, "subtmp");
		case T_MULT: return Builder.CreateMul(L, R, "multmp");
		case T_DIV: return Builder.CreateSDiv(L, R, "divtmp");
		case T_LEFTSHIFT: return Builder.CreateShl(L, R, "shltmp");
		case T_RIGHTSHIFT: return Builder.CreateLShr(L, R, "lshrtmp");
		case T_MOD: return Builder.CreateSRem(L, R, "modtmp");
		case T_LT: return Builder.CreateICmpSLT(L, R, "lttmp");
		case T_GT: return Builder.CreateICmpSGT(L, R, "gttmp");
		case T_LEQ: return Builder.CreateICmpSLE(L, R, "leqtmp");
		case T_GEQ: return Builder.CreateICmpSGE(L, R, "geqtmp");
		case T_AND: return Builder.CreateAnd(L, R, "andtmp");
		case T_OR: return Builder.CreateOr(L, R, "ortmp");
		case T_EQ: return Builder.CreateICmpEQ(L, R, "eqtmp");
		case T_NEQ: return Builder.CreateICmpNE(L, R, "neqtmp");
		default: throw runtime_error("operator not found " + string(1, (char)Op));
	}
}

llvm::Value *UnaryExprAST::Codegen() {
	if (NULL == Expr) {
		throw runtime_error("invalid unary expression");
	}
	llvm::Value *Val = Expr->Codegen();
	if (NULL == Val) {
		throw runtime_error("invalid unary expression");
	}

	switch (Op) {
		case T_MINUS:
			if (! Val->getType()->isIntegerTy(32)) {
				throw runtime_error("type mismatch for unary minus");
			}
			return Builder.CreateNeg(Val, "negtmp");
		case T_NOT:
			if (! Val->getType()->isIntegerTy(1)) {
				throw runtime_error("type mismatch for unary negation");
			}
			return Builder.CreateNot(Val, "nottmp");
		default:
			throw runtime_error("operator not found " + string(1, (char)Op));
	}
}

llvm::Value *AssignVarAST::Codegen() {
	if (NULL == Value) {
		throw runtime_error("invalid assignment");
	}
	llvm::Value *rvalue = Value->Codegen();
	if (rvalue == NULL) {
		throw runtime_error("no viable r-value found");
	}
	const llvm::PointerType *ptrTy = rvalue->getType()->getPointerTo();
	llvm::AllocaInst *Alloca = (llvm::AllocaInst *)syms.access_symtbl(Name);
	if (NULL == Alloca) {
		throw runtime_error("no declaration found for " + Name);
	}
	llvm::Value *val = Builder.CreateStore(rvalue, Alloca);
	if (ptrTy != Alloca->getType()) {
			throw runtime_error("type mismatch in assignment");
	}
	if (NULL == val) {
		throw runtime_error("problem creating store " + Name);
	}
	return val;
}

llvm::Value *AssignArrayLocAST::Codegen() {
        llvm::Value *Foo = syms.access_symtbl(Name);
        if (NULL == Foo) {
		throw runtime_error("no declaration found for " + Name);
        }
        llvm::Value *ArrayLoc = Builder.CreateStructGEP(Foo, 0, "arrayloc");
        llvm::Value *ArrayIndex = Builder.CreateGEP(ArrayLoc, Index->Codegen(), "arrayindex");
        llvm::Value *ArrayStore = Builder.CreateStore(Value->Codegen(), ArrayIndex); // Foo[8] = 1
        return ArrayStore;
}

llvm::Value *ArrayLocExprAST::Codegen() {
        llvm::Value *Foo = syms.access_symtbl(Name);
        if (NULL == Foo) {
		throw runtime_error("no declaration found for " + Name);
        }
        llvm::Value *ArrayLoc = Builder.CreateStructGEP(Foo, 0, "arrayloc");
        llvm::Value *ArrayIndex = Builder.CreateGEP(ArrayLoc, Expr->Codegen(), "arrayindex");
        llvm::Value *ArrayLoad = Builder.CreateLoad(ArrayIndex, "loadtmp");
        return ArrayLoad;
}

llvm::Value *BlockAST::Codegen() {
	// create a new scope for function args and block for method declaration
	syms.new_symtbl();
	llvm::Value *val = NULL;
	if (Vars != NULL) val = Vars->Codegen();
	if (Statements != NULL) val = Statements->Codegen();
	syms.remove_symtbl();
	return val;
}

llvm::Value *MethodBlockAST::Codegen() {
	llvm::Value *val = NULL;
	if (Vars != NULL) val = Vars->Codegen();
	if (Statements != NULL) val = Statements->Codegen();
	return val;
}

llvm::Value *IfStmtAST::Codegen() {
	//branches to condition check block
	llvm::Function* func = Builder.GetInsertBlock()->getParent();
	llvm::BasicBlock* branchBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "ifstart", func);
	Builder.CreateBr(branchBB);
	Builder.SetInsertPoint(branchBB);

	//branch to then, else block or then, end block
	llvm::Value* condV = Cond->Codegen();
	llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "iftrue", func);
	llvm::BasicBlock* endBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "end", func);
	llvm::BasicBlock* elseBB = NULL;
	if(ElseBlock != NULL) {
		elseBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "iffalse", func);
		Builder.CreateCondBr(condV, thenBB, elseBB);
	}else {
		Builder.CreateCondBr(condV, thenBB, endBB);
	}

	//codegens then block
	Builder.SetInsertPoint(thenBB);
	llvm::Value* thenVal;
	if(IfTrueBlock != NULL) {
		thenVal = IfTrueBlock->Codegen();
	}

	//codegens end block
	Builder.CreateBr(endBB);
	Builder.SetInsertPoint(endBB);

	//codegens else block
	llvm::Value* elseVal;
	if(ElseBlock != NULL) {
		Builder.SetInsertPoint(elseBB);
		elseVal = ElseBlock->Codegen();
		Builder.CreateBr(endBB);
		Builder.SetInsertPoint(endBB);
	}

	return endBB;
}

llvm::Value *WhileStmtAST::Codegen() {

	//branches to condition check block
	llvm::Function* func = Builder.GetInsertBlock()->getParent();
	llvm::BasicBlock* branchBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "loop", func);
	continueBlocks.push_front(branchBB);
	Builder.CreateBr(branchBB);
	Builder.SetInsertPoint(branchBB);

	//branches to loop body or end
	llvm::Value* condV = Cond->Codegen();
	llvm::BasicBlock* bodyBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "body", func);
	llvm::BasicBlock* endBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "end", func);
	endBlocks.push_front(endBB);
	Builder.CreateCondBr(condV, bodyBB, endBB);

	//body block
	Builder.SetInsertPoint(bodyBB);
	Body->Codegen();
	endBlocks.pop_front();
	continueBlocks.pop_front();
	Builder.CreateBr(branchBB);

	//end block
	Builder.SetInsertPoint(endBB);

	return endBB;
}

llvm::Value *ForStmtAST::Codegen() {

	InitList->Codegen();
	llvm::Function* func = Builder.GetInsertBlock()->getParent();
	llvm::BasicBlock* branchBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "loop", func);
	Builder.CreateBr(branchBB);
	Builder.SetInsertPoint(branchBB);

	//LoopEndList->Codegen();
	llvm::Value* condV = Cond->Codegen();
	llvm::BasicBlock* bodyBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "body", func);
	llvm::BasicBlock* nextBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "next", func);
	continueBlocks.push_front(nextBB);
	llvm::BasicBlock* endBB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "end", func);
	endBlocks.push_front(endBB);
	Builder.CreateCondBr(condV, bodyBB, endBB);

	Builder.SetInsertPoint(bodyBB);
	Body->Codegen();
	endBlocks.pop_front();
	continueBlocks.pop_front();
	Builder.CreateBr(nextBB);

	Builder.SetInsertPoint(nextBB);
	LoopEndList->Codegen();
	Builder.CreateBr(branchBB);

	Builder.SetInsertPoint(endBB);

	return endBB;
}

llvm::Value *ReturnStmtAST::Codegen() {
	llvm::Function *func = Builder.GetInsertBlock()->getParent();
	if (NULL == func) {
		throw runtime_error("could not find parent function");
	}
	if (NULL == Value) {
		if (func->getReturnType() == Builder.getVoidTy()) {
			return Builder.CreateRetVoid();
		} else {
			// according to the C spec, return void from non-void function is allowed.
			// so we silently create a default value for non-void functions
			// but really it should be an error.
			// Q: change it for next time?
			if (func->getReturnType()->isIntegerTy(32))
				return Builder.CreateRet(Builder.getInt32(0));
			if (func->getReturnType()->isIntegerTy(1))
				return Builder.CreateRet(Builder.getInt1(true));
			throw runtime_error("type mismatch in return value");
		}
	} else {
		llvm::Value *val = Value->Codegen();
		if (NULL == val) {
			throw runtime_error("invalid return value");
		}
		if (func->getReturnType() == val->getType()) {
			return Builder.CreateRet(val);
		} else {
			throw runtime_error("type mismatch in return value");
		}
	}
}

llvm::Value *BreakStmtAST::Codegen() {
	llvm::BasicBlock* block = endBlocks.front();
	return Builder.CreateBr(block);
}

llvm::Value *ContinueStmtAST::Codegen() {
	llvm::BasicBlock* block = continueBlocks.front();
	return Builder.CreateBr(block);
}

llvm::Value *MethodDeclAST::Codegen() {
	llvm::Function *func = (llvm::Function *)syms.access_symtbl(Name);
	if (NULL == func) {
		func = insertDeclare(ReturnType, Name, FunctionArgs);
	}
	// create a new scope for function args and block for method declaration
	syms.new_symtbl();

	// Create a new basic block which contains a sequence of LLVM instructions
	llvm::BasicBlock *BB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "entry", func);
	// insert into symbol table
	syms.enter_symtbl(string("entry"), BB);
	// All subsequent calls to IRBuilder will place instructions in this location
	Builder.SetInsertPoint(BB);

	// Set names for all arguments and allocate on stack
	if (NULL != FunctionArgs) {
		FunctionArgs->setArgNames(func);
	}

	// process method block
	if (NULL != Block) {
		llvm::Value *val = Block->Codegen();
		llvm::BasicBlock *CurBB = Builder.GetInsertBlock();
		if ((NULL == val) || (NULL == CurBB->getTerminator())) {
			if (func->getReturnType()->isVoidTy())
				Builder.CreateRetVoid();
			if (func->getReturnType()->isIntegerTy(32))
				Builder.CreateRet(Builder.getInt32(0));
			if (func->getReturnType()->isIntegerTy(1))
				Builder.CreateRet(Builder.getInt1(true));
		}
	} else {
		throw runtime_error("strangely empty block in method declaration");
	}

	syms.remove_symtbl();
	return func;
}

llvm::Value *AssignGlobalVarAST::Codegen() {
        llvm::Type *llvmTy = getLLVMType(Ty);
        llvm::GlobalVariable *gv = new llvm::GlobalVariable(*TheModule, llvmTy, false, llvm::GlobalValue::InternalLinkage, (llvm::Constant *)Value->Codegen(), Name.c_str());
        syms.enter_symtbl(Name, gv);
	return gv;
}

llvm::Value *FieldDecl::Codegen() {
	llvm::Value *val = NULL;
        llvm::Type *ty = NULL;

        if (this->getSize() == -1) {
            ty = this->getType();
        } else {
            ty = this->getArrayType();
        }
        val = defineGlobalVariableNoInitVal(ty, this->getName());

	return val;
}

llvm::Value *FieldDeclListAST::Codegen() {
	llvm::Value *val = NULL;
	for (list<class FieldDecl *>::iterator i = arglist.begin(); i != arglist.end(); i++) {
	    val = (*i)->Codegen();
	}
	return val;
}

llvm::Value *ClassAST::Codegen() {
	llvm::Value *val = NULL;
	TheModule->setModuleIdentifier(llvm::StringRef(Name));
	if (NULL != FieldDeclList) {
		val = FieldDeclList->Codegen();
	}
	if (NULL != MethodDeclList) {
		val = MethodDeclList->insertDeclares();
		val = MethodDeclList->Codegen();
	} else {
		throw runtime_error("no methods defined in class");
	}
	// Q: should we enter the class name into the symbol table?
	// syms.enter_symtbl(Name,val);
	return val;
}

llvm::Value *ExternAST::Codegen() {
	llvm::Type *returnTy = getLLVMType(ReturnType);
	std::vector<llvm::Type *> args;
	if (NULL != FunctionArgs) {
		FunctionArgs->typedArgList(args); // fill up the args vector with types
	}
	llvm::Value *Func = llvm::Function::Create(
		llvm::FunctionType::get(returnTy, args, false),
		llvm::Function::ExternalLinkage,
		Name,
		TheModule
	);
	syms.enter_symtbl(Name, Func);
	return Func;
}

llvm::Value *ProgramAST::Codegen() {
	llvm::Value *val = NULL;
	if (NULL != ExternList) {
		val = ExternList->Codegen();
	}
	if (NULL != ClassDef) {
		val = ClassDef->Codegen();
	} else {
		throw runtime_error("no class definition in decaf program");
	}
	return val;
}
