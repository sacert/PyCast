
#ifndef _DECAF_DEFS
#define _DECAF_DEFS

#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/IR/IRBuilder.h"
#include <cstdio> 
#include <cstdlib>
#include <cstring> 
#include <string>
#include <stdexcept>

using namespace std;

extern int lineno;
extern int tokenpos;

static bool shortcircuit = false;

extern "C"
{
	extern int yyerror(const char *);
	int yyparse(void);
	int yylex(void);  
	int yywrap(void);
}

#endif

