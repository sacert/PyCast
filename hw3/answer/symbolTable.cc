#include "llvm/Analysis/Verifier.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include <string>
#include <map>
#include <list>
#include <cstdlib>
#include <iterator>
#include <iostream>
#include "description.cc"

using namespace std;

class symbolTable {

private:

	typedef std::map<string, description*> symTable;
	typedef std::list<symTable*> symTableList;

	symTableList* symTblList;

public:

	symbolTable() {
		symTblList = new symTableList();
	}

	~symbolTable() {
		for(int i=0;i<symTblList->size();i++) {
			removeTable();
		}
		delete symTblList;
	}

	void addTable() {
		symTable* table = new symTable();
		symTblList->push_front(table);
	}

	void addSymbol(string name, int type, int register_dest, int memory_addr, int lineNum, bool spilled, llvm::Value* value) {
		symTable* table = symTblList->front();
		description* descripter = new description(type, register_dest, memory_addr, lineNum, spilled, value);
		//if(!alreadyDefined(name)) {
			(*table)[name] = descripter;
		//}else {
		//	std::cerr << " // defining an already defined variable" << std::endl;
		//	exit(1);
		//}
	}

	bool alreadyDefined(std::string name) {
		symTable* table = symTblList->front();
		symTable::iterator itr = table->find(name);
		if(itr == table->end()) {
			return false;
		}else {
			return true;
		}
	}

	void removeTable() {
		symTable* tablePtr = symTblList->front();
		delete tablePtr;
		symTblList->pop_front();
	}

	description* getSymbol(string name) {
		for(symTableList::iterator i = symTblList->begin();i != symTblList->end();i++) {
			symTable::iterator tableItr;
			if((tableItr = (*i)->find(name)) != (*i)->end()) {
				return tableItr->second;
			}
		}
		return NULL;
	}

};
