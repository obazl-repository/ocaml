load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "ModuleInfo",
     "HybridExecutableMarker", "TestExecutableMarker")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "exec_common_attrs")

load("//bzl/rules:COMPILER.bzl", "OCAML_COMPILER_OPTS")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("test_executable.bzl", "test_executable")

load(":test_transitions.bzl",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition"
     )

load(":batch_test_impl.bzl", "batch_test_impl")

## batch_test_macro
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

#############################
batch_in_transitions = dict(
    vv = vv_test_in_transition,
    vs = vs_test_in_transition,
    ss = ss_test_in_transition,
    sv = sv_test_in_transition,
)

#####################
## Batch rule definitions
def batch_rule(kind):

    return rule(
        implementation = batch_test_impl,
        doc = "Run a test executable built with {} compiler".format(kind),
        attrs = batch_attrs(kind),
        cfg = batch_in_transitions[kind],
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
def batch_test_macro(name,
                     stdout_actual, stdout_expected,
                     test_module,
                     opts  = OCAML_COMPILER_OPTS,
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

    batch_vv_test(
        name     = vv_name,
        test_executable = executable, # + ".vv.byte",
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vv"],
        **kwargs
    )

    batch_vs_test(
        name     = vs_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vs"],
        **kwargs
    )

    batch_ss_test(
        name     = ss_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["ss",],
        **kwargs
    )

    batch_sv_test(
        name     = sv_name,
        test_executable = executable,
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["sv"],
        **kwargs
    )

    test_executable(
        name    = executable,
        main    = test_module,
        opts    = opts,
        **kwargs
    )

    ## TODO: flambda test rules
