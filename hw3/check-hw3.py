#!/usr/bin/env python
"""
The specific TC.STAGE* files are:
	TC.STAGE	main result from STAGE
	TC.STAGE.out	standard output from STAGE
	TC.STAGE.err	standard error from STAGE
	TC.STAGE.ret	exit status from STAGE
These intermediate files go in the -o output path if it is given.

The TC.{out,err,ret} files represent the compiling process as a whole, and are not checked. The compiling process is always considered to succeed unless there is an internal error, even if the code generation stage fails (ie TC.llvm.ret may contain a non-zero number, but TC.ret will contain zero).
"""

import check
import os
import os.path
import difflib
import re
import sys

codegen = "expr-codegen"
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

def decaf_expr_command(**args):
    source_file = testcase_prefix(args['testcases_path'], args['group'], (args['testcase'])) + source_extension
    codegen_binary = os.path.join(os.getcwd(), codegen)
    return [os.path.join(args['check_dir'], testcase_run), "-c", codegen_binary, "-l", stdlib, source_file, args['log_dir'], args['group'], args['testcase']]

def command(**args):
    #print >>sys.stderr, "command:", [os.path.join(os.getcwd(), args['group'])]
    return [os.path.join(os.getcwd(), args['group'])]

def source_files(**args):
    #print >>sys.stderr, "source_files:", [args['group']]
    return [args['group']]

def edgews_normalize(*parts):
    def filter(x):
        x = [l.strip() for l in x]
        return [l + '\n' for l in x if l != '']
    return [filter(x) for x in parts]

def diff_almost_exact(a, b, output):
    a, b = edgews_normalize(a, b)
    if a != b:
            output.write("Diff in output:\n")
            output.writelines(difflib.unified_diff(a, b))
            return False
    return True

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
    "decaf-sym": 
        { 
            'command': command, 
            'source_files': source_files,
            'stdout': diff_exact,
            'stderr': None,
            'file_checks': []
        },
    "expr-codegen": {},
    "func-codegen": {}
}

check_defaults = {
        'command': decaf_expr_command,
        'source_files': [codegen],
        'stdout': None,
        'stderr': None,
        'file_checks': [make_file_check_llvm_err, make_file_check_run_out]
    } 

check.check_all(checks, check_defaults, extra_usage=__doc__.rstrip('\n\r'))

