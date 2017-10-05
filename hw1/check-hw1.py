#!/usr/bin/env python
"""
The specific TC.STAGE* files are:
	TC.STAGE	main result from STAGE
	TC.STAGE.out	standard output from STAGE
	TC.STATE.err	standard error from STAGE
	TC.STAGE.ret	exist status from STAGE
These intermediate files go in the -o output path if it is given.

The TC.{out,err,ret} files represent the compiling process as a whole, and are not checked. The compiling process is always considered to succeed unless there is an internal error, even if the code generation stage fails (ie TC.llvm.ret may contain a non-zero number, but TC.ret will contain zero).
"""

import check
import os
import os.path
import difflib
import re
import sys

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

def check_defaults(**args):
    return {
        'command': command,
        'source_files': source_files,
        'stdout': diff_exact,
        'stderr': None,
        'file_checks': []
    }

checks = {
        "rmcomments": { 'stdout': diff_almost_exact },
        "idtoken": {},
        "tokenizer": {},
        "decaflex": {},
#        "leftcontext": {},
#        "reject": {},
#        "bigram": {},
    }

check.check_all(checks, check_defaults, extra_usage=__doc__.rstrip('\n\r'))
