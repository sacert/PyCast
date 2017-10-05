#!/usr/bin/env python2
"""
Here the testcase groups are arbitrary. Each testcase is run by calling the expected compiler program to convert source code to LLVM code, then doing the complete compiling process to produce a native executable, and finally running the native executable.

The source code for testcase TC should be in a file called TC%s. The standard input to the native executable is from TC.in. The compiling process generates many intermediate result files which are named TC.STAGE*, where stage is one of the following:
	llvm	source code to LLVM code generation (the compiler being checked)
	bc	assembly to LLVM bitcode
	s	bitcode to native code
	exec	linking to make native executable
	run	running the final executable.
The specific TC.STAGE* files are:
	TC.STAGE	main result from STAGE
	TC.STAGE.out	standard output from STAGE
	TC.STATE.err	standard error from STAGE
	TC.STAGE.ret	exist status from STAGE
These intermediate files go in the -o output path if it is given. TC.llvm.ret and TC.run.out are checked against the corresponding files from the testcase.

The TC.{out,err,ret} files represent the compiling process as a whole, and are not checked. The compiling process is always considered to succeed unless there is an internal error, even if the code generation stage fails (ie TC.llvm.ret may contain a non-zero number, but TC.ret will contain zero).
"""

import check
import os
import os.path
import difflib
import re
import sys

codegen = "./decaf-codegen"
source_extension = ".decaf"
testcase_run = "llvm-run"
stdlib = "decaf-stdlib.c"

def testcase_prefix(testcases_path, group, testcase):
    return os.path.join(testcases_path, group, testcase)

def load_files(*paths):
    files = [open(fn) for fn in paths]
    try:
        return [list(f) for f in files]
    finally:
        for file in files:
            file.close()

def command(**args):
    source_file = testcase_prefix(args['testcases_path'], args['group'], (args['testcase'])) + source_extension
    return [os.path.join(args['check_dir'], testcase_run), "-c", codegen, "-l", stdlib, source_file, args['log_dir'], args['group'], args['testcase']]

def diff_exact(a, b, output):
    if a != b:
        output.write("Diff in output:\n")
        output.writelines(difflib.unified_diff(a, b))
        return False
    return True

def make_diff_exit_status(fail_fail_msg, fail_succeed_msg):
    def diff(a, b, output):
        try:
            # Normalize to 0 or 1 rather than checking exact error codes
            assert len(a) == 1
            assert len(b) == 1
            a, b = [0 if x == 0 else 1 for x in [int(y[0].strip()) for y in [a, b]]]
        except:
            output.write("Expected an exit status number but got something else.\n")
            return False
        if a != b:
            if a == 0:
                output.write("%s\n" % (fail_fail_msg))
            else:
                output.write("%s\n" % (fail_succeed_msg))
            output.write("Diff in output:\n")
            output.writelines(difflib.unified_diff([str(a)], [str(b)]))
            return False
        return True
    return diff

def gold_output_paths(suffix, **args):
    gold_path = testcase_prefix(args['testcases_path'], args['group'], (args['testcase'])) + suffix
    output_path = testcase_prefix(args['log_dir'], args['group'], (args['testcase'])) + suffix
    return gold_path, output_path

def make_file_check_llvm_err(**args):
    gold_path, output_path = gold_output_paths(".llvm.ret", **args)
    diff_exit_status = make_diff_exit_status("Testcase was expected to succeed but failed.", "Testcase was expected to fail but succeeded.")
    return { 'gold': gold_path, 'output': output_path, 'check': diff_exit_status, 'load_lines': True, 'backup': False, 'gold_default': ['0'], 'name': "code generation exit status" }

def make_file_check_run_out(**args):
    gold_path, output_path = gold_output_paths(".run.out", **args)
    return { 'gold': gold_path, 'output': output_path, 'check': diff_exact, 'load_lines': True, 'backup': False, 'gold_default': [], 'name': "final output from compiled program" }

checks = {
        "contest": {},
    }

check_defaults = {
        'command': command,
        'source_files': [codegen],
        'stdout': None,
        'stderr': None,
        'file_checks': [make_file_check_llvm_err, make_file_check_run_out]
    } 

check.check_all(checks, check_defaults, extra_usage=__doc__.rstrip('\n\r') % (source_extension))
