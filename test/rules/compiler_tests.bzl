load("@bazel_skylib//lib:paths.bzl", "paths")

# load("//test:rules.bzl",
#      "inline_expect_module",
load("//test/rules:ocamlcc_diff_test.bzl",
     "ocamlcc_diff_tests",
     "ocamlcc_diff_test")
# load("//test/rules:test_program.bzl", "test_program")
load("//test/rules:test_module.bzl", "test_module")
load("//test/rules:test_signature.bzl", "test_signature")

load(":UTILS.bzl", "std_compilers", "validate_io_files")

load("//test/rules:normalizers.bzl",
     "test_stderr_normalize",
     "test_stdlog_normalize")

###############################################################
####  MACRO
################################################################
def compile_module_tests(name,
                         structfile = None,
                         cmi        = None,
                         sigfile    = None,
                         compilers = std_compilers,
                         opts  = [],
                         dump = [],  # log, e.g. lambda
                         alerts = [],
                         warnings = {},
                         debug = False,

                         deps = [],
                         sig_deps = [],
                         stdlib_deps = [],
                         suppress_cmi = None,

                         rc_expected     = 0,
                         stdout_expected = None,
                         stdout_actual = None,
                         stderr_expected = None,
                         stderr_actual = None,
                         stdlog_expected = None,
                         stdlog_actual = None,

                         tags  = [],
                         timeout = "short",
                         **kwargs):

    if name.endswith("_tests"):
        stem = name[:-6]
        m_name = stem[:1].capitalize() + stem[1:]
    else:
        fail("compile_module_tests: name must end with '_tests'; actual: {}".format(name))

    if structfile and sigfile:
        fail("only one of structfile and sigfile allowed")

    if sigfile and cmi:
        fail("only one of sigfile and cmi allowed")

    if cmi and not structfile:
        fail("cmi must have matching structfile")

    validate_io_files(stdout_expected,
                      stdout_actual,
                      stderr_expected,
                      stderr_actual,
                      stdlog_expected,
                      stdlog_actual)

    (mstem, mext) = paths.split_extension(structfile)
    # print("NAME: %s" % name)
    # print("MSTEM: %s" % mstem)

    if stderr_actual:
        if stderr_expected == None:
            ## verify that stderr_actual is null
            expectation = None
            actual      = stderr_actual
        else:
            expectation = stderr_expected + ".norm"
            actual      = stderr_actual + ".norm"
    elif stdout_actual:
        if stdout_expected == None:
            ## verify that stderr_actual is null
            expectation = None
            actual      = stdout_actual
        else:
            expectation = stdout_expected + ".norm"
            actual      = stdout_actual + ".norm"
    elif stdlog_actual:
        if stdlog_expected == None:
            ## verify that stdlog_actual is null
            expectation = None
            actual      = stdlog_actual
        else:
            expectation = stdlog_expected + ".norm"
            actual      = stdlog_actual + ".norm"

    ocamlcc_diff_tests(
        name          = name,
        compilers     = compilers,
        expected      = expectation,
        actual        = actual,
        timeout       = timeout
    )

    # e.g. warnings/w03
    if stderr_actual and stderr_expected:
        test_stderr_normalize(
            name          = m_name + "_norm",
            src           = structfile,
            expected      = stderr_expected,
            expected_out  = stderr_expected + ".norm",
            actual        = stderr_actual,
            actual_out    = stderr_actual + ".norm",
        )

    if stdlog_actual and stdlog_expected:
        test_stdlog_normalize(
            name          = m_name + "_norm",
            src           = structfile,
            expected      = stdlog_expected,
            expected_out  = stdlog_expected + ".norm",
            actual        = stdlog_actual,
            actual_out    = stdlog_actual + ".norm",
        )

    test_module(
        name          = m_name,
        struct        = structfile,
        sig           = cmi,
        deps          = deps,
        sig_deps      = sig_deps,
        stdlib_deps   = stdlib_deps,
        suppress_cmi  = suppress_cmi,

        opts          = opts,
        dump          = dump,
        alerts        = alerts,
        warnings      = warnings,
        debug         = debug,

        rc_expected   = rc_expected,
        stdout_actual = stdout_actual,
        stderr_actual = stderr_actual,
        stdlog_actual = stdlog_actual,
    )

###############################################################
####  MACRO
################################################################
def compile_signature_tests(name,
                            sigfile    = None,
                            compilers = std_compilers,
                            opts  = [],
                        ## FIXME: do we need to support -dlambda for sigs?
                            dump = [],  # log, e.g. lambda
                            alerts = [],
                            warnings = {},
                            debug = False,

                            deps = [],
                            sig_deps = [],
                            stdlib_deps = [],

                            stdout_expected = None,
                            stdout_actual = None,
                            stderr_expected = None,
                            stderr_actual = None,
                            stdlog_expected = None,
                            stdlog_actual = None,

                            tags  = [],
                            timeout = "short",
                            **kwargs):

    if name.endswith("_sig_tests"):
        stem = name[:-10]
        m_name = stem[:1].capitalize() + stem[1:]
    else:
        fail("compile_signature_tests: name must end with '_sig_tests'; actual: {}".format(name))

    (sigstem, mext) = paths.split_extension(sigfile)
    # print("SIGSTEM: %s" % sigstem)
    sig_mname = sigstem[:1].capitalize() + sigstem[1:]

    validate_io_files(stdout_expected,
                      stdout_actual,
                      stderr_expected,
                      stderr_actual,
                      stdlog_expected,
                      stdlog_actual)

    ocamlcc_diff_tests(
        name          = name,
        compilers     = compilers,
        expected      = stderr_expected + ".sig_norm",
        actual        = stderr_actual + ".sig_norm",
        timeout       = timeout
    )

    # e.g. warnings/w32
    if stderr_actual:
        test_stderr_normalize(
            name          = sig_mname + "_sig_norm",
            expected      = stderr_expected,
            expected_out  = stderr_expected + ".sig_norm",
            actual        = stderr_actual,
            actual_out    = stderr_actual + ".sig_norm",
        )

    test_signature(
        name   = sig_mname + "_cmi",
        src    = sigfile,
        stdlib_deps = stdlib_deps,

        opts   = opts,
        # dump   = dump,
        alerts = alerts,
        warnings = warnings,
        debug = debug,

        stdout_actual = stdout_actual,
        stderr_actual = stderr_actual,
        stdlog_actual = stdlog_actual,
    )

