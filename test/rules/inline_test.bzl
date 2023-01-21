## WARNING: this rule only used once, for //tools:cvt_emit.byte

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "exec_common_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load("//bzl/rules:COMPILER.bzl", "OCAML_COMPILER_OPTS")

load("test_executable.bzl", "test_executable")

load(":test_transitions.bzl", "test_in_transitions")

load(":inline_test_impl.bzl", "inline_test_impl")

load("//bzl:providers.bzl",
     "ModuleInfo",
     "HybridExecutableMarker", "TestExecutableMarker")

#######################
def inline_attrs(kind):
    return dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = [[TestExecutableMarker],
                         [HybridExecutableMarker]], # -custom runtime
            default = None,
        ),

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
    )

#####################
## Inline rule definitions
def inline_rule(kind):

    return rule(
        implementation = inline_test_impl,
        doc = "Run an inline test executable built with {} compiler".format(kind),
        attrs = inline_attrs(kind),
        cfg = test_in_transitions[kind],
        test = True,
        fragments = ["cpp"],
        toolchains = ["//toolchain/type:ocaml",
                      "@bazel_tools//tools/cpp:toolchain_type"])

#######################
inline_vv_test = inline_rule("vv")
inline_vs_test = inline_rule("vs")
inline_ss_test = inline_rule("ss")
inline_sv_test = inline_rule("sv")

###############################################################
####  MACRO - generates inline_**_test targets
################################################################
def inline_test_macro(name,
                      test_module,
                      opts  = OCAML_COMPILER_OPTS,
                      timeout = "short",
                      **kwargs):

    if name.endswith("_test"):
        stem = name[:-5]
    else:
        stem = name

    if test_module.startswith(":"):
        test_name = test_module[1:]
    else:
        test_name = test_module
    print("test_name: %s" % test_name)

    executable = test_name + ".exe"

    vv_name = test_name + "_vv_test"
    vs_name = test_name + "_vs_test"
    ss_name = test_name + "_ss_test"
    sv_name = test_name + "_sv_test"

    print("vv_name: %s" % vv_name)

    native.test_suite(
        name  = stem + "_test",
        tests = [vv_name, vs_name, ss_name, sv_name]
    )

    inline_vv_test(
        name = vv_name,
        test_executable = executable,
        timeout = timeout,
        tags = ["vv", "inline"],
        **kwargs
    )

    inline_vs_test(
        name = vs_name,
        test_executable = executable,
        timeout = timeout,
        tags = ["vs", "inline"],
        **kwargs
    )

    inline_ss_test(
        name = ss_name,
        test_executable = executable,
        timeout = timeout,
        tags = ["ss", "inline"],
        **kwargs
    )

    inline_sv_test(
        name = sv_name,
        test_executable = executable,
        timeout = timeout,
        tags = ["sv", "inline"],
        **kwargs
    )

    test_executable(
        name    = executable,
        main    = test_module,
        opts    = opts,
        **kwargs
    )
