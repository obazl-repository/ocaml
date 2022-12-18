load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:test_transitions.bzl", "ss_test_in_transition")

load("//bzl:functions.bzl", "get_workdir")

load(":expect_test_impl.bzl", "expect_test_impl")

## expect_ss_test

#######################
expect_ss_test = rule(
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
    ## FIXME: use two toolchain adapters instead of transitioning?
    cfg = ss_test_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
