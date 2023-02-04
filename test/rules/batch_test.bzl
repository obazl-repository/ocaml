load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "ModuleInfo",
     "HybridExecutableMarker", "TestExecutableMarker")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "exec_common_attrs")

load("//bzl/rules:COMPILER.bzl", "OCAML_COMPILER_OPTS")

load(":test_program.bzl", "test_program")
load(":test_module.bzl", "test_module")

load(":test_transitions.bzl", "test_in_transitions")

load(":batch_test_impl.bzl", "batch_test_impl")

## batch_tests
## expands to batch_xx_test where xx == vv | vs | ss | sv

## builds an executable and runs it
## executable is expected to write to stdout
## batch_test redirects output to file,
## then diffs it against expected output.

#################
def batch_attrs(kind):

    if kind in ["vv", "sv"]:
        providers = [[TestExecutableMarker],
                     [HybridExecutableMarker]] # -custom runtime
    else:
        providers = [[TestExecutableMarker]]

    return dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = providers,
            default = None,
        ),

        stdout_actual = attr.string( ),
        stdout_expected = attr.label(
            allow_single_file = True,
        ),

        log_actual = attr.string( ),
        log_expected = attr.label(
            allow_single_file = True,
        ),

        diff_args = attr.string_list(
            default = ["-w"]
        ),

        _runtime = attr.label(
            #WARNING: cc_import may not produce a single file, even if
            # it impports a single file.
            # allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
        ),

        _rule = attr.string( default = "batch_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    )

#####################
## Batch rule definitions
def batch_rule(kind):

    return rule(
        implementation = batch_test_impl,
        doc = "Run a test executable built with {} compiler".format(kind),
        attrs = batch_attrs(kind),
        cfg = test_in_transitions[kind],
        test = True,
        fragments = ["cpp"],
        toolchains = ["//toolchain/type:ocaml",
                      "@bazel_tools//tools/cpp:toolchain_type"])

#######################
batch_vv_test = batch_rule("vv")
batch_vs_test = batch_rule("vs")
batch_ss_test = batch_rule("ss")
batch_sv_test = batch_rule("sv")

###############################################################
####  MACRO - generates two test targets plus on test_suite
################################################################
def batch_tests(name,
                     test_module,
                     # log_actual = None,
                     # log_expected = None,
                     stdout_actual, ## = None,
                     stdout_expected, ## = None,
                     # stderr_actual = None,
                     # stderr_expected = None,
                     opts  = [],
                     tags  = [],
                     timeout = "short",
                     **kwargs):

    if name.endswith("_test"):
        stem = name[:-5]
    else:
        stem = name

    if test_module.startswith(":"):
        test_name  = test_module[1:]
    else:
        test_name = test_module
    executable = test_name + ".exe"

    vv_name = test_name + "_vv_test"
    vs_name = test_name + "_vs_test"
    ss_name = test_name + "_ss_test"
    sv_name = test_name + "_sv_test"

    native.test_suite(
        name  = stem + "_test",
        tests = [vv_name, vs_name, ss_name, sv_name]
    )

    # test_run_program(
    #     name     = vv_name,
    #     compiler = ...
    #     test_executable = executable, # + ".vv.byte",
    #     stdout_actual   = stdout_actual,
    #     stdout_expected = stdout_expected,
    #     timeout  = timeout,
    #     tags     = ["vv"] + tags,
    #     **kwargs
    # )

    batch_vv_test(
        name     = vv_name,
        test_executable = executable, # + ".vv.byte",
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vv"] + tags,
        **kwargs
    )

    batch_vs_test(
        name     = vs_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vs"] + tags,
        **kwargs
    )

    batch_ss_test(
        name     = ss_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["ss"] + tags,
        **kwargs
    )

    batch_sv_test(
        name     = sv_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["sv"] + tags,
        **kwargs
    )

    ## TODO: flambda test rules

###############################################################
####  MACRO - generates native tests
################################################################
def batch_native_tests(name,
                       struct,
                       stdout_expected,
                       stdout_actual = None,
                       stdlib_deps = [],
                       # stderr_actual = None,
                       # stderr_expected = None,
                       opts  = [],
                       tags  = [],
                       timeout = "short",
                       **kwargs):

    if name.endswith("_test"):
        stem = name[:-5]
    else:
        stem = name

    if struct.startswith(":"):
        structfile = struct[1:]
    else:
        structfile = struct
    executable = name + ".exe"

    vs_name = stem + "_vs_test"
    ss_name = stem + "_ss_test"

    native.test_suite(
        name  = stem + "native_tests",
        tests = [vs_name, ss_name]
    )

    batch_vs_test(
        name     = vs_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vs"] + tags,
        **kwargs
    )

    batch_ss_test(
        name     = ss_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["ss"] + tags,
        **kwargs
    )

    test_program(
        name    = executable,
        main    = ":" + stem,
        opts    = OCAML_COMPILER_OPTS + opts,
        **kwargs
    )

    test_module(
        name   = stem,
        struct = struct,
        stdlib_deps = stdlib_deps,
        **kwargs
    )

    ## TODO: flambda test rules
