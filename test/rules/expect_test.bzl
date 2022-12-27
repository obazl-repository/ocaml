load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load(":test_transitions.bzl",
     "vv_test_in_transition",
     # "vs_test_in_transition",
     "ss_test_in_transition",
     # "sv_test_in_transition"
     )

load(":expect_test_impl.bzl", "expect_test_impl")

# load(":expect_vv_test.bzl", "expect_vv_test")
# load(":expect_ss_test.bzl", "expect_ss_test")

## expect_test macro
## expands to expect_xx_test where xx == vv | vs | ss | sv

## builds an executable and runs it
## executable is expected to write to stdout
## expect_test redirects output to file,
## then diffs it against expected output.

#######################
ocamlc_byte_expect_test = rule(
    implementation = expect_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),

        stdout   = attr.string( ),
        expected = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            allow_single_file = True,
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
expect_ss_test = rule(
    implementation = expect_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),

        stdout   = attr.string( ),
        expected = attr.label(
            allow_single_file = True,
        ),

        _runtime = attr.label(
            allow_single_file = True,
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

###############################################################
####  MACRO - generates two test targets plus on test_suite
################################################################
def expect_test(name, stdout, expected, main, timeout = "short",
                **kwargs):

    if name.endswith("_test"):
        stem = name
    else:
        stem = name + "_test"

    vv_name = "ocamlc.byte." + name
    vs_name = "ocamlopt.byte." + name
    ss_name = "ocamlopt.opt." + name
    sv_name = "ocamlc.opt." + name

    native.test_suite(
        name  = name,
        tests = [vv_name, ss_name]
    )

    ocamlc_byte_expect_test(
        name     = vv_name,
        stdout   = stdout,
        expected = expected,
        main     = main,
        timeout  = timeout,
        tags     = ["ocamlc.byte"],
        **kwargs
    )

    expect_ss_test(
        name     = ss_name,
        stdout   = stdout,
        expected = expected,
        main     = main,
        timeout  = timeout,
        tags     = ["ocamlopt.opt"],
        **kwargs
    )
