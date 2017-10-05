
lexlib=l
yacclib=y
bindir=.
rm=/bin/rm -f
mv=/bin/mv -f
#targets=multexpr varexpr
#cpptargets=expr-interpreter expr-parse decaf-ast json
targets=expr-interpreter
cpptargets=expr-parse decaf-ast

all: $(targets) $(cpptargets)

$(targets): %: %.y
	@echo "compiling yacc file:" $<
	@echo "output file:" $@
	bison -o$@.tab.c -d $<
	flex -o$@.lex.c $@.lex
	gcc -o $(bindir)/$@ $@.tab.c $@.lex.c -l$(yacclib) -l$(lexlib) -lm
	$(rm) $@.tab.c $@.tab.h $@.lex.c

$(cpptargets): %: %.y
	@echo "compiling cpp yacc file:" $<
	@echo "output file:" $@
	bison -b $@ -d $<
	$(mv) $@.tab.c $@.tab.cc
	flex -o$@.lex.cc $@.lex
	g++ -o $(bindir)/$@ $@.tab.cc $@.lex.cc -l$(yacclib) -l$(lexlib) -lm
	$(rm) $@.tab.h $@.tab.cc $@.lex.cc

test: $(targets) $(cpptargets)
	@echo "testing Question 5 ..."
	echo "x + y * ( z )" | $(bindir)/expr-parse
	@echo "testing Question 7 ..."
	cat ../catalan.decaf | $(bindir)/decaf-ast
	cat quicksort.decaf | $(bindir)/decaf-ast

testall: $(targets) $(cpptargets)
	@echo "testing Question 1 ..."
	cat ../simple-expr-testfile.txt | ./simple-expr2
	@echo "testing Question 2 ..."
	cat ../expr-testfile.txt | ./expr-interpreter
	cat expr-testfile2.txt | ./expr-interpreter
	@echo "testing Question 3 ..."
	cat quicksort.decaf
	@echo "testing Question 4 ..."
	cat decafGrammar.txt
	@echo "testing Question 5 ..."
	echo "x + y * ( z )" | $(bindir)/expr-parse
	@echo "testing Question 6 ..."
	cat decafSmallLRGrammar.txt
	@echo "testing Question 7 ..."
	cat catalan.decaf | $(bindir)/decaf-parse
	cat quicksort.decaf | $(bindir)/decaf-parse

clean:
	$(rm) $(targets) $(cpptargets)
	$(rm) *.tab.h *.tab.c *.lex.c

