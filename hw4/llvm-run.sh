#!/bin/bash

if [ $# != 4 ]; then
	echo "usage: $0 GROUP TESTCASE DECAF-FILE LOG-DIR" 1>&2
	exit 1
fi
group=$1
testcase=$2
decaf_file=$3
log_dir=$4

decafcodegen=./decaf-codegen
llvmas=llvm-as
llc=llc
gcc=gcc
decafstdlib=decaf-stdlib.c
out_prefix=$log_dir/$group/$testcase
id=$group.$testcase
mkdir -p "$log_dir/$group"

run() {
	echo -n "$1... " 1>&2
	eval "$2" 1>"$out_prefix$3.out" 2>"$out_prefix$3.err"
	err=$?
        echo $err 1>"$out_prefix$3.ret"
	if [ $err -eq 0 ]; then
		echo "ok"
	else
		echo "failed ($err)"
	fi 1>&2
        cat "$out_prefix$3.out"
        cat "$out_prefix$3.err" 1>&2
	[ $err -ne 0 ] && exit 0
}

touch "$out_prefix.run.out" # empty final output in case we fail during the build

run "generating llvm code" "$decafcodegen" ".llvm" < "$decaf_file"
cp "$out_prefix.llvm.err" "$out_prefix.llvm"
run "assembling to bitcode" "$llvmas $out_prefix.llvm -o $out_prefix.llvm.bc" ".llvm.bc" < /dev/null
run "converting to native code" "$llc -disable-cfi $out_prefix.llvm.bc -o $out_prefix.llvm.s" ".llvm.s" < /dev/null
run "linking" "$gcc -o $out_prefix.llvm.exec $out_prefix.llvm.s $decafstdlib" ".exec" < /dev/null
run "running" "$out_prefix.llvm.exec" ".run"
exit 0
