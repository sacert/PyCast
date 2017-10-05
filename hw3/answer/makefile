
lexlib=l
yacclib=y
bindir=.
rm=/bin/rm -f
mv=/bin/mv -f
#targets= decaf-sym
cpptargets=decaf-sym
#llvmtargets=factorial
#llvmcpp=sexpr2-codegen expr-codegen
#llvmfiles=rec_add
llvmcpp=expr-codegen#decaf-sym expr-codegen

all: $(targets) $(cpptargets) $(llvmcpp) $(llvmfiles)

$(targets): %: %.y
	@echo "compiling yacc file:" $<
	@echo "output file:" $@
	bison -o$@.tab.c -d $<
	flex -o$@.lex.c $@.lex
	gcc -o $(bindir)/$@ $@.tab.c $@.lex.c -l$(yacclib) -l$(lexlib)
	$(rm) $@.tab.c $@.tab.h $@.lex.c

$(cpptargets): %: %.y
	@echo "compiling cpp yacc file:" $<
	@echo "output file:" $@
	bison -b $@ -d $<
	$(mv) $@.tab.c $@.tab.cc
	flex -o$@.lex.cc $@.lex
	g++ -o $(bindir)/$@ $@.tab.cc $@.lex.cc -l$(yacclib) -l$(lexlib)
	$(rm) $@.tab.h $@.tab.cc $@.lex.cc

$(llvmcpp): %: %.y
	@echo "compiling cpp yacc file:" $<
	@echo "output file:" $@
	bison -b $@ -d $<
	$(mv) $@.tab.c $@.tab.cc
	flex -o$@.lex.cc $@.lex
	gcc -g -c decaf-stdlib.c
	g++ -o $(bindir)/$@ $@.tab.cc $@.lex.cc decaf-stdlib.o -Wl,--no-as-needed `llvm-config --cppflags --ldflags --libs core jit native` -l$(yacclib) -l$(lexlib)
	$(rm) $@.tab.h $@.tab.cc $@.lex.cc

$(llvmtargets): %: %.ll
	@echo "using llvm to compile file:" $<
	llvm-as $<
	`llvm-config --bindir`/llc -disable-cfi $@.bc
	gcc $@.s ../decaf-stdlib.c -o $(bindir)/$@

$(llvmfiles): %: %.ll
	@echo "using llvm to compile file:" $<
	llvm-as $<
	`llvm-config-3.3 --bindir`/llc -disable-cfi $@.bc
	clang $@.s decaf-stdlib.c -o $(bindir)/$@

clean:
	$(rm) $(targets) $(cpptargets) $(llvmtargets) $(llvmcpp) $(llvmfiles)
	$(rm) *.tab.h *.tab.c *.lex.c
	$(rm) *.bc *.s *.o
	$(rm) -r *.dSYM

