
Important: you must use LLVM 3.3. check with llvm-config --version
(it is installed on the Linux machines)

The filenames for each question are given below.  We will grade
only the questions marked with a dagger in the PDF file.  They are
marked with + below.

All text output should be printed to standard output (stdout). Just
use printf or cout which prints to stdout by default. In some
cases you will need to print to stderr, in which case use cerr.

Programs that take input must read it from standard input (stdin).
By default lex/flex and yacc/bison reads from stdin and printf
prints to stdout.

The hw3/testcases directory contains useful test cases; the mapping
between the homework questions and test cases is given below. The
list below shows the binaries that will be tested. We must be able
to create the binaries by running 'make' in the answer directory.
The easiest way to use make is to edit the file 'answer/makefile'
and add your lex program name (without any suffix) to targets or
cpptargets (if C++). If you add 'prog' to targets in answer/makefile
then running 'make' in the answer directory will create the binary
'prog' from 'prog.y'

Test your programs by running: "python check-hw3.py". Run without
arguments and it will print out a detailed help text about usage
and grading.

If the auto check above gives exit failure make sure that you are
always using exit(0) as the last line of your main function in your
C or C++ code. Use exit(1) to indicate failure.

Note that marker-nojoy.y will not be acceptable to bison. For the
reason, first check what marker-nojoy.y is trying to do, and then
check the correct syntax for bison in expr-inherit.y

decaf-stdlib.c is the decaf standard library containing the print_int,
print_string, and read_int functions that can be used in Decaf
programs. In the full Decaf compiler we will enforce that such
external functions must be defined in the extern definition list
but for this homework we will use the Decaf standard library
functions without having to declare them as externs.

For checking if your decaf-sym program works, you can use
the unix command 'nl' to check that the output of your
program matches the line number of the variable definition.
e.g. 'nl decaf-file.in' would print out the line numbers
in the input file so you can check against your output line
numbers for each usage of the variable.

When using g++ and LLVM on the CSIL Linux machines you
must include the options -Wl,--no-as-needed in your g++
command line.

You can use my makefile to automatically compile various
types of files:

targets: simple C lex and yacc programs
cpptargets: C++ lex and yacc programs
llvmcpp: C++ program that uses LLVM API
llvmfiles: LLVM assembly files
llvmtargets: C++ lex and yacc programs that uses LLVM API

For example, if you want to test a LLVM assembly
program such as helloworld.ll then add the filename
without the extension to the llvmfiles line in the
makefile:

llvmfiles=helloworld

Then run make which will create the binary file
helloworld which can be then run:

./helloworld 


Create a file called HANDLE in your hw3/answer directory which contains
your group handle (no spaces). Each member of the group should write
a readme file (readme.name) and explain her/his role in each homwork.

Put all your answer programs in 'answer/' directory and just submit 
'answer/' (including makefile) on courses.cs.sfu.ca


%%

+q2: decaf-sym
+q8: expr-codegen


