"""
usage: %s [options] ANSWER-DIR TESTCASE-DIR [...]

ANSWER-DIR      Directory where your answer source files are stored.
TESTCASE-DIR    Directory with testcases to be checked.

Options:
	-B	Disable backups of existing extra files produced by during checking. If set then the existing files will be overwritten without confirmation.
	-o DIR	Save the output from the testcases to DIR. Will overwrite existing files in DIR. Useful for debugging your code. DIR will always contain the output and exit status of the processes executed during checks. It may also contain extra intermediate files.
	-d	Show a comparison of outputs in a diff-like format for each failed testcase. For testcases where output is not matched exactly, the diff will show a comparison where the output and expected output are in a normalized form. Read the diff functions (listed at the end of the usage output) if the diff is not clear.
	-s FILE	Skip all testcases indicated by FILE. Each line in FILE is either a group name, in which case all testcases for that group will be skipped; or a group name and a testcase name, in which case the specific testcase will be skipped for that group.
"""

import sys
import os
import os.path
import shutil
import tempfile
import subprocess
import collections
import shlex
import pipes
import pprint
import operator

class SourceNotFound(Exception):
  def __init__(self, missing_files):
    self.missing_files = missing_files

def expand(x, group, testcase, testcases_path, log_dir, check_dir):
    if callable(x):
        opts = { 'group': group, 'testcase': testcase, 'testcases_path': testcases_path, 'log_dir': log_dir, 'check_dir': check_dir }
        for key, value in opts.items():
            if value is None:
                del opts[key]
        x = x(**opts)
    return x
def expand_list(xs, *args):
    return [expand(x, *args) for x in xs]
def expand_dict(xs, *args, **opts):
    skip = opts.get('skip') or []
    return dict((k, x if k in skip else expand(x, *args)) for (k, x) in xs.iteritems())
def expand_all(checks, check_defaults, group, testcase, testcases_path, log_dir, check_dir):
    args = [group, testcase, testcases_path, log_dir, check_dir]
    checks = dict(checks)
    checks = expand(checks, *args)
    check_defaults = expand(check_defaults, *args)
    for group, group_check in checks.items():
        group_check = merge_defaults(group_check, check_defaults)
        group_check = expand(group_check, *args)
        group_check = expand_dict(group_check, *args, skip=['stdout', 'stderr'])
        group_check['source_files'] = expand_list(group_check['source_files'], *args)
        group_check['file_checks'] = [expand_dict(fc, *args, skip=['check']) for fc in expand_list(group_check['file_checks'], *args)]
        checks[group] = group_check
    return checks

def merge_defaults(options, defaults):
    options = dict(options)
    for key, value in defaults.iteritems():
        if key not in options:
            options[key] = value
    return options

def mkdirp(path):
    try:
        os.makedirs(path)
    except os.error:
        pass
def maybe_rel_path(path, rel_to):
    if not os.path.isabs(path):
        path = os.path.join(rel_to, path)
    return path

def run(argv, stdin_file=None, output_path=None):
    """
    Runs a command specified by an argument vector (including the program name)
    and returns lists of lines from stdout and stderr.
    """
    if output_path is not None:
        dir = os.path.dirname(output_path)
        mkdirp(dir)
        stdout_path = "%s.out" % (output_path)
        stderr_path = "%s.err" % (output_path)
        stdout_file = open(stdout_path, 'w')
        stderr_file = open(stderr_path, 'w')
        status_path = "%s.ret" % (output_path)
    else:
        stdout_file, stdout_path = tempfile.mkstemp("stdout")
        stderr_file, stderr_path = tempfile.mkstemp("stderr")
        status_path = None
    try:
        try:
            prog = subprocess.Popen(argv, stdin=stdin_file or subprocess.PIPE, stdout=stdout_file, stderr=stderr_file)
            if stdin_file is None:
                prog.stdin.close()
            prog.wait()
        finally:
            if output_path is not None:
                stdout_file.close()
                stderr_file.close()
            else:
                os.close(stdout_file)
                os.close(stderr_file)
        if status_path is not None:
            with open(status_path, 'w') as status_file:
              print >> status_file, prog.returncode
        with open(stdout_path) as stdout_input:
            stdout_lines = list(stdout_input)
        with open(stderr_path) as stderr_input:
            stderr_lines = list(stderr_input)
        if prog.stdin != None:
            prog.stdin.close()
        return stdout_lines, stderr_lines, prog.returncode
    except:
        print >> sys.stderr, "error: something went wrong when trying to run the following command:"
        print >> sys.stderr, " ".join(pipes.quote(a) for a in argv)
        sys.exit(1)
    finally:
        if output_path is None:
            os.remove(stdout_path)
            os.remove(stderr_path)

def check_output(gold_lines, output_lines, check, diff_output=None):
    if check is not None:
        try:
            use_diff_output = open(os.devnull, 'w') if diff_output is None else diff_output
            return check(gold_lines, output_lines, use_diff_output)
        except Exception:
            if diff_output is None:
                use_diff_output.close()
            raise
    else:
        return True

def check_stdouterr_output(gold_path, output_lines, check, diff_output=None):
    if check is not None:
        if os.path.exists(gold_path):
            with open(gold_path) as file:
                lines = list(file)
        else:
            lines = []
        try:
            use_diff_output = open(os.devnull, 'w') if diff_output is None else diff_output
            return check(lines, output_lines, use_diff_output)
        except Exception:
            if diff_output is None:
                use_diff_output.close()
            raise
    else:
        return True

def check_file_output(gold_path, output_path, check, diff_output=None, load_lines=True, gold_default=None):
    if not os.path.exists(gold_path):
        if gold_default is None:
            print >> sys.stderr, "warning: missing gold file for file check, acting as if empty: %s" % (gold_path)
            gold_lines = []
        else:
            gold_lines = gold_default
    elif load_lines:
        with open(gold_path) as gold_file:
            gold_lines = list(gold_file)
    if not os.path.exists(output_path):
        print >> sys.stderr, "warning: missing output file for file check, failing: %s" % (output_path)
        return False
    elif load_lines:
          with open(output_path) as output_file:
              output_lines = list(output_file)
    else:
          gold_lines = None
          output_lines = None
    return check_output(gold_lines, output_lines, check, diff_output=diff_output)

def backup_files(dir, *paths):
    for path in paths:
        if os.path.exists(path):
            file, temp_path = tempfile.mkstemp(dir=dir, prefix=path + ".bak")
            os.close(file)
            os.remove(temp_path) # Apparently on Windows we have to remove the file before copying over it
            print >> sys.stderr, "renaming existing output file \"%s\" to \"%s\"" % (path, temp_path)
            os.rename(path, temp_path)
            assert not os.path.exists(path)

def run_testcase(testcases_path, group, testcase, checks, check_defaults, log_dir, do_backups=True, output_path=None, diff_output=None, check_dir=None):
    check = expand_all(checks, check_defaults, group, testcase, testcases_path, log_dir, check_dir)[group]
    command = list(check['command'])
    source_files = check['source_files']
    check_stdout = check['stdout']
    check_stderr = check['stderr']
    file_checks = check['file_checks']

    path = os.path.join(testcases_path, group)

    missing_source = [fn for fn in source_files if not os.path.exists(fn)]
    if len(missing_source) > 0:
        raise SourceNotFound(missing_source)
  
    file_path = os.path.join(path, "%s.file" % (testcase))
    input_path = os.path.join(path, "%s.in" % (testcase))
    args_path = os.path.join(path, "%s.cmd" % (testcase))
    gold_stdout_path = os.path.join(path, "%s.out" % (testcase))
    gold_stderr_path = os.path.join(path, "%s.err" % (testcase))
    fail_path = os.path.join(path, "%s.fail" % (testcase))

    if os.path.exists(file_path):
        if os.path.exists(input_path):
            print >> sys.stderr, "warning: testcase %s for %s has both a .file and a .in file"
        with open(file_path) as file_file:
            input_path = os.path.join(path, file_file.read().strip())

    if os.path.exists(args_path):
        with open(args_path) as file:
            args = shlex.split(file.read())
    else:
        args = []

    if do_backups:
        backup_files(os.getcwd(), *(fc['output'] for fc in file_checks if 'backup' not in fc or fc['backup']))

    input_file = None
    try:
        if os.path.exists(input_path):
            input_file = open(input_path)
        print >> sys.stderr, "running", group, testcase
        stdout, stderr, status = run(command + args, input_file, output_path=output_path)
        failed = []
        if os.path.exists(fail_path):
            if status == 0:
                failed.append("success exit value")
        else:
            if status != 0:
                failed.append("failure exit value")
        if not check_stdouterr_output(gold_stdout_path, stdout, check_stdout, diff_output):
            failed.append("stdout")
        if not check_stdouterr_output(gold_stderr_path, stderr, check_stderr, diff_output):
            failed.append("stderr")
        for file_check in file_checks:
            gold_path = maybe_rel_path(file_check['gold'], testcases_path)
            output_path = maybe_rel_path(file_check['output'], os.getcwd())
            if not check_file_output(gold_path, output_path, file_check['check'], diff_output, file_check.get('load_lines') or True, file_check.get('gold_default')):
                msg = output_path
                if 'name' in file_check:
                    msg = "%s (%s)" % (msg, file_check['name'])
                failed.append(msg)
        print >> sys.stdout, group, testcase, ":",
        if len(failed) > 0:
            print >> sys.stdout, "failed : %s" % (', '.join(failed))
            return False
        else:
            print >> sys.stdout, "passed"
            return True
    except Exception:
        if input_file is not None:
            input_file.close()
            print >> sys.stderr
        raise

def run_testcases(path, checks, check_defaults, do_backups=True, output_path=None, diff_output=None, skip=set(), log_dir=None, check_dir=None):
    counts = {}
    no_program = set()
    temp_log_dir = log_dir is None
    if temp_log_dir:
        log_dir = tempfile.mkdtemp()

    try:
        for group in sorted(checks.iterkeys()):
            counts.setdefault(group, (0, 0))
            subdir_path = os.path.join(path, group)
            testcases = set(f[:(i if i >= 0 else None)] for f in os.listdir(subdir_path) if not f[0] == '.' for i in [f.find('.')]) if os.path.isdir(subdir_path) else []
            if len(testcases) > 0:
                for testcase in sorted(testcases):
                    if (group,) in skip or (group, testcase) in skip:
                        print >> sys.stderr, "warning: skipping %s %s by manual choice" % (group, testcase)
                    else:
                        try:
                            output = os.path.join(output_path, group, testcase) if output_path is not None else None
                            passed = run_testcase(path, group, testcase, checks, check_defaults, log_dir, do_backups=do_backups, output_path=output, diff_output=diff_output, check_dir=check_dir)
                        except SourceNotFound as e:
                            print >> sys.stderr, "warning: skipping %s because the following source file%s not exist: %s" % (group, " does" if len(e.missing_files) == 1 else "s do", ', '.join(e.missing_files))
                            no_program.add(group)
                            passed = False
                        correct, total = counts.get(group)
                        counts[group] = (correct + int(passed), total + 1)
            else:
                print >> sys.stderr, "warning: no testcases for %s" % (group)
    finally:
        if temp_log_dir:
            shutil.rmtree(log_dir)

    return counts, no_program

def default_check_defaults():
    """
    Defaults for running python programs in files corresponding to the groups, using the current python interpreter executable.
    """
    def default_command(**args):
        group = args['group']
        if not group.endswith(".py"):
          group = "%s.py" % (group)
        return (sys.executable, group)
    def default_source_files(**args):
        group = args['group']
        if not group.endswith(".py"):
          group = "%s.py" % (group)
        return [group]
    check_defaults = {
              'command': default_command,
              'source_files': default_source_files,
              'stdout': None,
              'stderr': None,
              'file_checks': []
          }
    return check_defaults

def usage(progname, checks, check_defaults, check_dir, extra=None):
    checks = expand_all(checks, check_defaults, "GROUP", "TESTCASE", "TESTCASE-PATH", "OUTPUT-PATH", check_dir)
    pp = pprint.PrettyPrinter(indent=4)
    print >> sys.stderr, __doc__.strip('\n\r') % (progname)
    if extra is not None:
        print >> sys.stderr, extra
    print >> sys.stderr
    print >> sys.stderr, "Testcase groups and checks in use:"
    def fun_name(function):
        return function.__name__ if function is not None else "None"
    def format_file_check(file_check):
        text = "%s vs %s" % (file_check['gold'], file_check['output'])
        if 'name' in file_check:
            text += " (%s)" % (file_check['name'])
        return (text, file_check['check'])
    for group, check in checks.iteritems():
        print >> sys.stderr, "\t%s:" % (group)
        for name, check_fun in [("stdout", check['stdout']), ("stderr", check['stderr'])] + [format_file_check(fc) for fc in check['file_checks']]:
            print >> sys.stderr, "\t\t%s: %s" % (name, fun_name(check_fun))

def check_all(checks, check_defaults=default_check_defaults(), argv=sys.argv, extra_ops=None, extra_usage=None):
    import getopt

    check_dir = os.path.dirname(os.path.abspath(sys.argv[0]))

    try:
        opt_spec = "Bo:ds:"
        if extra_ops is not None:
            opt_spec += extra_ops[0]
        opts, args = getopt.getopt(argv[1:], opt_spec)
        do_backups = True
        output_path = None
        diff_output = None
        skip = set()
        for opt, value in opts:
            if opt == "-B":
                do_backups = False
            elif opt == "-o":
                output_path = os.path.abspath(value)
            elif opt == "-d":
                diff_output = sys.stdout
            elif opt == "-s":
                with open(value) as file:
                    skip = set(tuple(line.split()) for line in file)
        if extra_ops is not None:
            extra_ops[1](opts)
        if len(args) < 2:
            raise getopt.GetoptError("Not enough arguments.")
    except getopt.GetoptError, e:
        usage(sys.argv[0], checks, check_defaults, check_dir, extra=extra_usage)
        sys.exit(1)

    answer_dir = args[0]
    testcase_paths = [os.path.abspath(p) for p in args[1:]]
    os.chdir(answer_dir)

    for testcase_path in testcase_paths:
        counts, no_program = run_testcases(testcase_path, checks, check_defaults, do_backups=do_backups, output_path=output_path, diff_output=diff_output, skip=skip, log_dir=output_path, check_dir=check_dir)
        for program, (correct, total) in counts.iteritems():
            print "%s : %i / %i%s" % (program, correct, total, " (missing source)" if program in no_program else "")
        print "total : %i / %i" % (sum(c for (c, t) in counts.itervalues()), sum(t for (c, t) in counts.itervalues()))
