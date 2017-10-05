#include "llvm/DerivedTypes.h"
#include "llvm/LLVMContext.h"
#include "llvm/Module.h"
#include "llvm/Type.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Support/IRBuilder.h"
#include <stdexcept>

using namespace std;

static llvm::Module *TheModule;
static llvm::IRBuilder<> Builder(llvm::getGlobalContext());

llvm::Function *genMainDef() {
  // create the top-level definition for main
  llvm::FunctionType *FT = llvm::FunctionType::get(Builder.getInt32Ty(), std::vector<llvm::Type*>(), false);
  llvm::Function *TheFunction = llvm::Function::Create(FT, llvm::Function::ExternalLinkage, "main", TheModule);
  if (TheFunction == 0) {
    throw runtime_error("empty function block"); 
  }
  // Create a new basic block which contains a sequence of LLVM instructions
  llvm::BasicBlock *BB = llvm::BasicBlock::Create(llvm::getGlobalContext(), "entry", TheFunction);
  // All subsequent calls to IRBuilder will place instructions in this location
  Builder.SetInsertPoint(BB);
  return TheFunction;
}

llvm::Function *genPrintIntDef() {
  // create a extern definition for print_int
  std::vector<llvm::Type*> args;
  args.push_back(Builder.getInt32Ty()); // print_int takes one i32 argument
  return llvm::Function::Create(llvm::FunctionType::get(Builder.getVoidTy(), args, false), llvm::Function::ExternalLinkage, "print_int", TheModule);
}

llvm::Function *genPrintStringDef() {
  // create a extern definition for print_string
  std::vector<llvm::Type*> args;
  args.push_back(Builder.getInt8PtrTy()); // print_string takes one string argument
  return llvm::Function::Create(llvm::FunctionType::get(Builder.getVoidTy(), args, false), llvm::Function::ExternalLinkage, "print_string", TheModule);
}

int main() {
  // initialize LLVM
  llvm::LLVMContext &Context = llvm::getGlobalContext();
  // Make the module, which holds all the code.
  TheModule = new llvm::Module("global scalar values and print_string example", Context);

  // declare a global variable
  llvm::GlobalVariable *Foo = new llvm::GlobalVariable(
    *TheModule, 
    Builder.getInt32Ty(), 
    false,  // variable is mutable
    llvm::GlobalValue::InternalLinkage, 
    Builder.getInt32(0), 
    "Foo"
  );

  llvm::Function *print_string = genPrintStringDef();
  llvm::Function *print_int = genPrintIntDef();
  llvm::Function *F = genMainDef();
  llvm::Value *footmp = Builder.CreateLoad(Foo, "footmp");
  llvm::Value *addtmp = Builder.CreateAdd(footmp, Builder.getInt32(1), "addtmp");
  llvm::Value *CallPI = Builder.CreateCall(print_int, addtmp);

  // define string as global variable
  llvm::Value *GlobalStr = Builder.CreateGlobalString("\nhello, world\n", "GlobalStr");

  // access string for print_string
  llvm::Value *Cast = Builder.CreateConstGEP2_32(GlobalStr, 0, 0, "cast");
  llvm::Value *CallPS = Builder.CreateCall(print_string, Cast);

  Builder.CreateRet(Builder.getInt32(0));
  llvm::verifyFunction(*F);
  TheModule->dump();
}
