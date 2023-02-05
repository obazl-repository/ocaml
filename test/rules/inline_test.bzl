## WARNING: this rule only used once, for //tools:cvt_emit.byte

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "exec_common_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load("//bzl/rules:COMPILER.bzl", "OCAML_COMPILER_OPTS")

load("test_program.bzl", "test_program")

load(":test_transitions.bzl", "test_in_transition")

load(":UTILS.bzl", "std_compilers", "get_test_name", "validate_io_files")

load(":inline_test_impl.bzl", "inline_assertion_test_impl")
load(":test_module.bzl", "test_module")

load("//bzl:providers.bzl",
     "ModuleInfo",
     "HybridExecutableMarker", "TestExecutableMarker")

#######################
def _inline_assertion_attrs():
    return dict(
        exec_common_attrs(),

        compiler = attr.string(
            doc = "ocamlc.byte | ocamlopt.opt | etc."
        ),

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
        _rule = attr.string( default = "inline_assertion_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    )

#####################
## Inline rule definitions
def inline_assertion_rule(kind):

    return rule(
        implementation = inline_assertion_test_impl,
        doc = "Run an inline_assertion pgm",
        attrs = _inline_assertion_attrs(),
        cfg = test_in_transition,  # s[kind],
        test = True,
        fragments = ["cpp"],
        toolchains = ["//toolchain/type:ocaml",
                      "@bazel_tools//tools/cpp:toolchain_type"])

#######################
inline_assertion_test = inline_assertion_rule("")

inline_assertion_vv_test = inline_assertion_rule("vv")
inline_assertion_vs_test = inline_assertion_rule("vs")
inline_assertion_ss_test = inline_assertion_rule("ss")
inline_assertion_sv_test = inline_assertion_rule("sv")

###############################################################
####  MACRO - generates inline_assertion_**_test targets
################################################################
def inline_assertion_tests(name,
                           structfile,
                           cmi        = None,
                           sigfile    = None,
                           compilers = std_compilers,
                           opts  = [],
                           alerts = [],
                           warnings = [],

                           deps = [],
                           sig_deps = [],
                           stdlib_deps = [],

                           timeout = "short",
                           **kwargs):

    if name.endswith("_tests"):
        stem = name[:-6]
        m_name = stem[:1].capitalize() + stem[1:]
    else:
        fail("inline_assertion_tests name must end in '_tests'")

    if structfile.startswith(":"):
        test_name = structfile[1:]
    else:
        test_name = structfile
    print("test_name: %s" % test_name)

    executable = m_name + ".exe"

    vv_name = test_name + "_vv_test"
    vs_name = test_name + "_vs_test"
    ss_name = test_name + "_ss_test"
    sv_name = m_name + "_sv_test"

    print("vv_name: %s" % vv_name)

    tests = []

    for compiler in compilers:
        if compiler not in std_compilers:
            fail("Unrecognized compiler: {c}. Valid compiler names: {cs}".format(
                c = compiler, cs=std_compilers
            ))
        tname, ctag = get_test_name(stem, compiler)
        tests.append(tname)
        inline_assertion_test(
            name = tname,
            test_executable = m_name + ".exe",
            timeout = timeout,
            tags = ["inline", ctag],
            **kwargs
        )


    # inline_assertion_vv_test(
    #     name = vv_name,
    #     test_executable = executable,
    #     timeout = timeout,
    #     tags = ["vv", "inline"],
    #     **kwargs
    # )

    # inline_assertion_vs_test(
    #     name = vs_name,
    #     test_executable = executable,
    #     timeout = timeout,
    #     tags = ["vs", "inline"],
    #     **kwargs
    # )

    # inline_assertion_ss_test(
    #     name = ss_name,
    #     test_executable = executable,
    #     timeout = timeout,
    #     tags = ["ss", "inline"],
    #     **kwargs
    # )

    test_program(
        name    = m_name + ".exe",
        main    = m_name,
        # opts    = OCAML_COMPILER_OPTS ## ???
    )

    test_module(
        name   = m_name,
        struct = structfile,
        sig    = cmi,
        sig_deps    = sig_deps,
        stdlib_deps = stdlib_deps,

        opts   = opts,
        alerts = alerts,
        warnings = warnings,

        # stdout_actual = stdout_actual,
        # stderr_actual = stderr_actual,
        # stdlog_actual = stdlog_actual,
    )

    native.test_suite(
        name  = m_name + "_tests",
        tests = tests
    )

