#include <string>

using namespace std;

class descriptor {

private:

	int type;
	int register_dest;
	int memory_addr;
	int lineNum;
	bool spilled;

public:

	const static int BOOL_TYPE = 1;
	const static int INT_TYPE = 2;

	descriptor() {

	}

	descriptor(int type, int register_dest, int memory_addr, int lineNum, bool spilled) {
		this->type = type;
		this->register_dest = register_dest;
		this->lineNum = lineNum;
		this->spilled = spilled;
	}

	~descriptor() {

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

};