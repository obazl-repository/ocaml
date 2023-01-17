load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "ModuleInfo",
     "HybridExecutableMarker", "TestExecutableMarker")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "exec_common_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("test_executable.bzl", test_executable = "test_executable")

load(":test_transitions.bzl",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition"
     )

load(":batch_expect_test_impl.bzl", "batch_expect_test_impl")

# load(":expect_vv_test.bzl", "expect_vv_test")
# load(":expect_ss_test.bzl", "expect_ss_test")

## expect_test macro
## expands to expect_xx_test where xx == vv | vs | ss | sv

## builds an executable and runs it
## executable is expected to write to stdout
## expect_test redirects output to file,
## then diffs it against expected output.

#######################
expect_vv_test = rule(
    implementation = batch_expect_test_impl,
    doc = "Run a test executable built with ocamlc.byte",
    attrs = dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = [[TestExecutableMarker], [HybridExecutableMarker]],
            default = None,
            # cfg = exe_deps_out_transition,
        ),

        stdout_actual = attr.string( ),
        stdout_expected = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            #WARNING: cc_import may not produce a single file, even if
            # it impports a single file.
            # allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _rule = attr.string( default = "expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = vv_test_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
expect_vs_test = rule(
    implementation = batch_expect_test_impl,
    doc = "Run a test executable built with ocamlopt.byte",
    attrs = dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = [[TestExecutableMarker]],
            default = None,
            # cfg = exe_deps_out_transition,
        ),

        stdout_actual = attr.string( ),
        stdout_expected = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            # allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _rule = attr.string( default = "expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = vs_test_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
expect_ss_test = rule(
    implementation = batch_expect_test_impl,
    doc = "Run a test executable built with ocamlopt.opt",
    attrs = dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = [[TestExecutableMarker]],
            default = None,
            # cfg = exe_deps_out_transition,
        ),

        stdout_actual   = attr.string( ),
        stdout_expected = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            ## allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _rule = attr.string( default = "expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = ss_test_in_transition,
    # cfg = build_tool_sys_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
expect_sv_test = rule(
    implementation = batch_expect_test_impl,
    doc = "Run a test executable built with ocamlc.opt",
    attrs = dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = [[TestExecutableMarker], [HybridExecutableMarker]],
            default = None,
            # cfg = exe_deps_out_transition,
        ),

        stdout_actual   = attr.string( ),
        stdout_expected = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            # allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _rule = attr.string( default = "expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = sv_test_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

###############################################################
####  MACRO - generates two test targets plus on test_suite
################################################################
def batch_expect_test(name,
                stdout_actual, stdout_expected,
                test_module,
                timeout = "short",
                **kwargs):

    if name.endswith("_test"):
        stem = name[:-5]
    else:
        stem = name

    if test_module.startswith(":"):
        executable = test_module[1:]
    else:
        executable = test_module

    vv_name = executable + "_vv_test"
    vs_name = executable + "_vs_test"
    ss_name = executable + "_ss_test"
    sv_name = executable + "_sv_test"

    test_executable(
        name    = executable,
        main    = executable,
        **kwargs
    )

    native.test_suite(
        name  = stem + "_test",
        tests = [vv_name, vs_name, ss_name, sv_name]
    )

    expect_vv_test(
        name     = vv_name,
        test_executable = executable + ".vv.byte",
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vv"],
        **kwargs
    )

    expect_vs_test(
        name     = vs_name,
        test_executable = executable + ".vs.opt",
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["vs"],
        **kwargs
    )

    expect_ss_test(
        name     = ss_name,
        test_executable = executable + ".ss.opt",
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["ss",],
        **kwargs
    )

    expect_sv_test(
        name     = sv_name,
        test_executable = executable + ".vv.byte",
        stdout_actual   = stdout_actual,
        stdout_expected = stdout_expected,
        timeout  = timeout,
        tags     = ["sv"],
        **kwargs
    )

    ## TODO: flambda test rules
