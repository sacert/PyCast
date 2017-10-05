#include "llvm/Analysis/Verifier.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include <string>

using namespace std;

class description {

private:

	int type;
	int register_dest;
	int memory_addr;
	int lineNum;
	bool spilled;
	llvm::Value* value;

public:

	description() {

	}

	description(int type, int register_dest, int memory_addr, int lineNum, bool spilled, llvm::Value* value) {
		this->type = type;
		this->register_dest = register_dest;
		this->lineNum = lineNum;
		this->spilled = spilled;
		this->value = value;
	}

	~description() {

	}

	int getLineNum() {
		return lineNum;
	}

	int getType() {
		return type;
	}

	int getRegisterDest() {
		return register_dest;
	}

	int getMemoryAddr() {
		return memory_addr;
	}

	bool isSpilled() {
		return spilled;
	}

	llvm::Value* getValue() {
		return value;
	}

};