load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:test_transitions.bzl", "vv_test_in_transition")
load("//bzl/transitions:tool_transitions.bzl",
     "build_tool_vm_in_transition")

load(":expect_test_impl.bzl", "expect_test_impl")

## expect_vv_test

#######################
expect_vv_test = rule(
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
    # cfg = vv_test_in_transition,
    cfg = build_tool_vm_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
