b=`basename -s .ll $1`
llvm-as $1
llc -disable-cfi $b.bc
gcc $b.s decaf-stdlib.c -o $b
./$b
rm -f $b.bc $b.s $b
