## WARNING: this rule only used once, for //tools:cvt_emit.byte

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load(":test_transitions.bzl",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition"
     )

##############################
def _inline_test_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    if tc.config_executor in ["boot", "baseline", "vm"]:
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, tc, exe_name, tc.workdir)

#######################
inline_vv_test = rule(
    implementation = _inline_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     # allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "inline_test" ),
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
inline_vs_test = rule(
    implementation = _inline_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     # allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "inline_test" ),
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
inline_ss_test = rule(
    implementation = _inline_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     # allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "inline_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = ss_test_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
inline_sv_test = rule(
    implementation = _inline_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     # allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "inline_test" ),
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
####  MACRO - generates inline_**_test targets
################################################################
def inline_test_macro(name,
                      main,
                      opts = [],
                      **kwargs):

    if name.endswith("_test"):
        stem = name[:-5]
    else:
        stem = name

    if main.startswith(":"):
        main = main[1:]
    else:
        main = main

    vv_name = main + "_inline_vv_test"
    vs_name = main + "_inline_vs_test"
    ss_name = main + "_inline_ss_test"
    sv_name = main + "_inline_sv_test"

    native.test_suite(
        name  = stem + "_test",
        tests = [vv_name, vs_name, ss_name, sv_name]
    )

    inline_vv_test(
        name = vv_name,
        main = main,
        **kwargs
    )

    inline_vs_test(
        name = vs_name,
        main = main,
        **kwargs
    )

    inline_ss_test(
        name = ss_name,
        main = main,
        **kwargs
    )

    inline_sv_test(
        name = sv_name,
        main = main,
        **kwargs
    )

