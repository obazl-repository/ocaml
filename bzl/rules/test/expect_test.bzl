load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/actions:module_impl.bzl", "module_impl")
# load("//bzl/actions:expect_impl.bzl", "expect_impl")

load("//bzl/transitions:transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load("//bzl:functions.bzl", "get_workdir")

load(":expect_vv_test.bzl", "expect_vv_test")
load(":expect_ss_test.bzl", "expect_ss_test")
load(":expect_test_impl.bzl", "expect_test_impl")

## expect_test

## builds an executable and runs it
## executable is expected to write to stdout
## expect_test redirects output to file,
## then diffs it against expected output.

###############################################################
def expect_test(name, stdout, expect, main, timeout = "short",
                **kwargs):

    native.test_suite(
        name  = name,
        tests = [":vv_" + name, "ss_" + name]
    )

    expect_vv_test(
        name    = "vv_" + name,
        stdout  = stdout,
        expect  = expect,
        main    = main,
        timeout = timeout,
        tags    = ["vv"],
        **kwargs
    )

    expect_ss_test(
        name    = "ss_" + name,
        stdout  = stdout,
        expect  = expect,
        main    = main,
        timeout = timeout,
        tags    = ["ss"],
        **kwargs
    )

#######################
expect_x_test = rule(
    implementation = expect_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),

        stdout = attr.string( ),
        expect = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain/dev:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _rule = attr.string( default = "expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    cfg = dev_tc_compiler_out_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
