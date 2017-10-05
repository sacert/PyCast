#include <string>
#include <map>
#include <list>
#include <cstdlib>
#include <iterator>
#include <iostream>
#include "descriptor.cc"

using namespace std;

class symTable {

private:

	typedef map<string, descriptor*> symbolTable;
	typedef list<symbolTable*> symbolTableList;

	symbolTableList* symTblList;

public:

	symTable() {
		symTblList = new symbolTableList();
	}

	~symTable() {
		for(int i=0;i<symTblList->size();i++) {
			removeTable();
		}
		delete symTblList;
	}

	void addTable() {
		symbolTable* table = new symbolTable();
		symTblList->push_front(table);
	}

	void addSymbol(string name, int type, int register_dest, int memory_addr, int lineNum, bool spilled) {
		symbolTable* table = symTblList->front();
		descriptor* description = new descriptor(type, register_dest, memory_addr, lineNum, spilled);
		if(!alreadyDefined(name)) {
			(*table)[name] = description;
		}else {
			cout << " // defining an already defined variable" << endl;
			exit(1);
		}
	}

	bool alreadyDefined(string name) {
		symbolTable* table = symTblList->front();
		symbolTable::iterator itr = table->find(name);
		if(itr == table->end()) {
			return false;
		}else {
			return true;
		}
	}

	void removeTable() {
		symbolTable* tablePtr = symTblList->front();
		delete tablePtr;
		symTblList->pop_front();
	}

	descriptor* getSymbol(string name) {
		for(symbolTableList::iterator i = symTblList->begin();i != symTblList->end();i++) {
			symbolTable::iterator tableItr;
			if((tableItr = (*i)->find(name)) != (*i)->end()) {
				return tableItr->second;
			}
		}
		return NULL;
	}

};