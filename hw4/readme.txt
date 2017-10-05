
Important: you must use LLVM 3.3. check with llvm-config --version
(it is installed on the Linux machines in Surrey campus)

globalarray.cc contains LLVM C++ code for defining and using arrays
as global variables.

Compile and run using:

g++ -g globalarray.cc `llvm-config --cppflags --ldflags --libs core jit native` -O3 -o globalarray

The output of globalarray.cc is already saved as globalarray.ll and
can be compiled to a binary by running make.

globalscalar.cc contains LLVM C++ code for defining and using scalar
global variables. It also contains example code for using the Decaf
print_string library method, which involves declaring and using a
constant string global.

Compile and run using:

g++ -g globalscalar.cc `llvm-config --cppflags --ldflags --libs core jit native` -O3 -o globalscalar

The output of globalscalar.cc is already saved as globalscalar.ll
and can be compiled to a binary by running make.

kscope.cc contains the the Kaleidoscope tutorial from the llvm.org
website. 

You need to pass all the testcases (q0/  q0-hw3/  q1/  q2/  q3/  q4/  q6-failure/  q6-success/). 

%%

+q5: decaf-codegen


