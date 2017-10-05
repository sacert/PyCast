
The filenames for each question are given below.  We will grade
only the questions marked with a dagger in the PDF file.  They are
marked with + below.

All text output should be printed to standard output (stdout). Just
use printf or cout which prints to stdout by default.

Programs that take input must read it from standard input (stdin).
By default lex reads from stdin and printf prints to stdout.

The hw1/testcases directory contains useful test cases; the mapping
between the homework questions and test cases is given below. The
list below shows the binaries that will be tested. We must be able
to create the binaries by running 'make' in the answer directory.
The easiest way to use make is to edit the file 'answer/makefile'
and add your lex program name (without any suffix) to targets or
cpptargets (if C++). If you add 'prog' to targets in answer/makefile
then running 'make' in the answer directory will create the binary
'prog' from 'prog.lex'

Test your programs by running: "python check-hw1.py". Run without
arguments and it will print out a detailed help text about usage
and grading.

If the auto check above gives exit failure make sure that you are
always using exit(0) as the last line of your main function in your
C or C++ code. Use exit(1) to indicate failure.

Create a file called HANDLE in your 'answer' directory which contains
your group handle (no spaces). Each member of the group should write
a readme file (readme.name) and explain her/his role in each homwork.

Put all your answer programs in 'answer/' directory and just submit 
'answer/' (including makefile) on courses.cs.sfu.ca


%%

+q1: rmcomments
+q2: idtoken
+q3: tokenizer
+q4: decaflex
q5: leftcontext
q6: reject
q7: bigram

