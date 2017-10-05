CC=gcc
CCC=g++
<<<<<<< HEAD
=======
#CC=clang
#CCC=clang++
>>>>>>> 295de6fe992b0fe6bc63151e45bbc47d77dd2833
lexlib=l
yacclib=y
bindir=.
cp=/bin/cp -f
rm=/bin/rm -f
mv=/bin/mv -f
targets=
cpptargets=
deps=decaf-ast.cc llvm-codegen.cc symboltable.cc
llvmcpp=expr-codegen

all: decaf-codegen
<<<<<<< HEAD

decaf-codegen: $(llvmcpp) $(cpp)
        $(cp) expr-codegen decaf-codegen

$(llvmcpp): %: %.y $(deps)
        @echo "compiling cpp yacc file:" $<
        @echo "output file:" $@
        bison -b $@ -d $<
        $(mv) $@.tab.c $@.tab.cc
        flex -o$@.lex.cc $@.lex
        gcc -g -c decaf-stdlib.c
        g++ -o $(bindir)/$@ $@.tab.cc $@.lex.cc decaf-stdlib.o -Wl,--no-as-needed `llvm-config-3.3 --cppflags --ldflags --libs core jit native` -l$(yacclib) -l$(lexlib)
        $(rm) $@.tab.h $@.tab.cc $@.lex.cc

clean:
        $(rm) decaf-codegen $(targets) $(cpptargets) $(llvmtargets) $(llvmcpp)
        $(rm) *.tab.h *.tab.c *.lex.c
        $(rm) *.bc *.s *.o
        $(rm) -r *.dSYM
=======

decaf-codegen: $(llvmcpp) $(cpp)
	$(cp) expr-codegen decaf-codegen

$(llvmcpp): %: %.y $(deps)
	@echo "compiling cpp yacc file:" $<
	@echo "output file:" $@
	bison -b $@ -d $<
	$(mv) $@.tab.c $@.tab.cc
	flex -o$@.lex.cc $@.lex
	$(CC) -g -c decaf-stdlib.c
	$(CCC) -o $(bindir)/$@ $@.tab.cc $@.lex.cc decaf-stdlib.o -Wl,--no-as-needed `llvm-config --cppflags --ldflags --libs core jit native` -l$(yacclib) -l$(lexlib)
	$(rm) $@.tab.h $@.tab.cc $@.lex.cc

clean:
	$(rm) decaf-codegen expr-codegen $(targets) $(cpptargets) $(llvmtargets) $(llvmcpp)
	$(rm) *.tab.h *.tab.c *.lex.c
	$(rm) *.bc *.s *.o
	$(rm) -r *.dSYM

>>>>>>> 295de6fe992b0fe6bc63151e45bbc47d77dd2833
