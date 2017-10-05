
lexlib=l
yacclib=y
bindir=.
rm=/bin/rm -f
mv=/bin/mv -f
targets=expr-inherit 
#targets=expr-inherit marker-nojoy
#cpptargets=expr-grammar
llvmcpp=kscope1
llvmfiles=add helloworld
llvmtargets=sexpr-codegen

all: $(targets) $(cpptargets) $(llvmfiles) $(llvmtargets) $(llvmcpp)

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

$(llvmtargets): %: %.y
	@echo "compiling cpp yacc file:" $<
	@echo "output file:" $@
	bison -b $@ -d $<
	$(mv) $@.tab.c $@.tab.cc
	flex -o$@.lex.cc $@.lex
	gcc -g -c decaf-stdlib.c
	g++ -o $(bindir)/$@ $@.tab.cc $@.lex.cc decaf-stdlib.o -Wl,--no-as-needed `llvm-config --cppflags --ldflags --libs core native` -l$(yacclib) -l$(lexlib)
	$(rm) $@.tab.h $@.tab.cc $@.lex.cc 

$(llvmcpp): %: %.cc
	@echo "using llvm to compile file:" $<
	g++ -g $< -Wl,--no-as-needed `llvm-config --cppflags --ldflags --libs core jit native` -O3 -o $(bindir)/$@

$(llvmfiles): %: %.ll
	@echo "using llvm to compile file:" $<
	llvm-as $<
	`llvm-config --bindir`/llc -disable-cfi $@.bc
	gcc $@.s decaf-stdlib.c -o $(bindir)/$@

test: $(targets) $(cpptargets)
	@echo "inherited attributes in yacc ..."
	echo "2 + 3 + 4" | $(bindir)/expr-inherit

clean:
	$(rm) $(targets) $(cpptargets) $(llvmtargets) $(llvmcpp) $(llvmfiles)
	$(rm) *.tab.h *.tab.c *.tab.cc *.lex.c *.lex.cc
	$(rm) *.bc *.s *.o
	$(rm) -r *.dSYM
