load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl",
     "executable_attrs",
     "exec_common_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl:providers.bzl",
     "ModuleInfo",
     "HybridExecutableMarker",
     "TestExecutableMarker")

load("//bzl/rules:COMPILER.bzl", "OCAML_COMPILER_OPTS")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load(":UTILS.bzl", "std_compilers", "validate_io_files")

load(":test_transitions.bzl",
     "test_in_transition",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition")

load(":ocamlcc_diff_test.bzl", "ocamlcc_diff_tests")
load(":test_module.bzl", "test_module")

##############################
def _test_program_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    # if tc.config_executor in ["boot", "vm"]:
    #     ext = ".byte"
    # else:
    #     ext = ".opt"

    if hasattr(ctx.attr, "stem"):
        if ctx.attr.stem:
            exe_name = ctx.attr.stem
        else:
            exe_name = ctx.attr.main[ModuleInfo].name
    else:
        exe_name = ctx.attr.main[ModuleInfo].name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
test_program = rule(
    implementation = _test_program_impl,
    doc = "Links OCaml executable binary using ocamlc.byte",
    attrs = dict(
        executable_attrs(),
        stem = attr.string(
            doc = "Used to construct executable name. Default uses filename in 'main' as stem."
        ),

        compiler = attr.label(
            doc = "Sets //toolchain:compiler and //toolchain:runtime.",
            allow_single_file = True,
        ),

        stdout = attr.output(),
        stderr = attr.output(),
        stdlog = attr.output(), # for e.g. -dlambda dumpfile

        _runfiles_bash = attr.label(
            allow_single_file = True,
            default = "@bazel_tools//tools/bash/runfiles"
        ),

        verbose = attr.bool(),
        _sh_verbose = attr.label(default = "//testsuite/tests:verbose"),

        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_program" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    cfg = test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _test_program_outputs_impl(ctx):

    debug = False

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    pgm = ctx.file.test_executable

    compiler = tc.compiler[DefaultInfo].files_to_run.executable
    (compiler_stem, compiler_ext) = paths.split_extension(compiler.basename)

    if HybridExecutableMarker in ctx.attr.test_executable:
        # exec was built by vm compiler with -custom
        #FIXME: do we really need HybridExecutableMarker?
        ocamlrun = None
        ocamlrun_path = ""
        pgm_cmd = pgm.path
    else: # which compiler was used to build the executable?
        if compiler_stem ==  "ocamlc":
            ocamlrun      = tc.ocamlrun
            ocamlrun_path = tc.ocamlrun.path
            pgm_cmd = tc.ocamlrun.path + " ocamlcc/" + pgm.path
        elif compiler_stem in ["ocamlopt", "ocamloptx"]:
            ocamlrun = None
            ocamlrun_path = ""
            pgm_cmd = pgm.path

    if debug:
        print("pgm: %s" % pgm)
        if HybridExecutableMarker in ctx.attr.test_executable:
            print("hybrid!")
        print("tc.name: %s" % tc.name)
        print("compiler: %s" % compiler)
        print("tc.config_executor: %s" % tc.config_executor)
        print("tc.config_emitter: %s" % tc.config_emitter)
        print("exe file to run: %s" % ctx.attr.test_executable.files_to_run.executable)
        print("pgm: %s" % pgm)
        print("ocamlrun: %s" % tc.ocamlrun)
        print("pgm_cmd: %s" % pgm_cmd)
        print("STDOUT: %s" % ctx.outputs.stdout)

    action_outputs = []
    if ctx.outputs.stdout:
        stdout = "1> {}".format(ctx.outputs.stdout.path)
        action_outputs.append(ctx.outputs.stdout)
    else:
        stdout = ""

    if ctx.outputs.stderr:
        stderr = "2> {}".format(ctx.outputs.stderr.path)
        action_outputs.append(ctx.outputs.stderr)
    else:
        stderr = ""

    ctx.actions.run_shell(
        inputs    = depset(),
        outputs   = action_outputs,
        arguments = [], # args],
        tools = [pgm] + ([ocamlrun] if ocamlrun else []),
        command = " ".join([
            "{}".format(ocamlrun_path),
            "{}".format(pgm.path),
            stdout,
            stderr
        ]),
        mnemonic = "BatchTestRun",
        # progress_message = progress_msg(workdir, ctx)
    )

    defaultInfo = DefaultInfo(
        files = depset(action_outputs),
    )

    return [defaultInfo]

######################
# batch_test_run = rule(
test_program_outputs = rule(
    implementation = _test_program_outputs_impl,
    doc = "Run a test executable",
    attrs = dict(
        exec_common_attrs(),

        test_executable = attr.label(
            doc = "Label of test executable.",
            mandatory = True,
            allow_single_file = True,
            providers = # if kind in ["vv", "sv"]:
            [[TestExecutableMarker],
             [HybridExecutableMarker]], # -custom runtime
            # else:
            #     providers = [[TestExecutableMarker]]

            default = None,
        ),

        stdout = attr.output(
            mandatory = True
        ),

        stderr = attr.output(
            mandatory = False
        ),

        # stdout_expected = attr.label(
        #     allow_single_file = True,
        # ),

        log_actual = attr.string( ),
        # log_expected = attr.label(
        #     allow_single_file = True,
        # ),

        # diff_args = attr.string_list(
        #     default = ["-w"]
        # ),

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
    ),
    # cfg = test_in_transitions[kind],
    # executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"])

###############################################################
####  MACRO - expands to:
## test_suite()
## ocamlcc_diff_tests() - expands to one ocamlcc_diff_test per compiler
## test_program_outputs()
## test_program()
## test_module()

##FIXME: name 'program_tests'?

def module_program_tests(name,
                         structfile,
                         cmi        = None,
                         sigfile    = None,
                         compilers = std_compilers,
                         opts  = [],
                         dump = [],  # log, e.g. lambda
                         alerts = [],
                         warnings = [],

                         deps = [],
                         sig_deps = [],
                         stdlib_deps = [],
                         suppress_cmi = None,

                         stdout_expected = None,
                         # stdout_actual = None,
                         stderr_expected = None,
                         # stderr_actual = None,
                         stdlog_expected = None,
                         # stdlog_actual = None,

                         tags  = [],
                         timeout = "short",
                         **kwargs):

    if name.endswith("_tests"):
        stem = name[:-6]
        m_name = stem[:1].capitalize() + stem[1:]
    else:
        fail("module_program_tests: name must end with '_tests'; actual: {}".format(name))

    ## FIXME: other validations?

    # validate_io_files(stdout_expected,
    #                   stdout_actual,
    #                   stderr_expected,
    #                   stderr_actual,
    #                   stdlog_expected,
    #                   stdlog_actual)

    (mstem, mext) = paths.split_extension(structfile)
    print("NAME: %s" % name)
    print("MSTEM: %s" % mstem)

    ocamlcc_diff_tests(
        ## expands to test_suite and one ocamlcc_diff_test per compiler
        name          = name,
        compilers     = compilers,
        expected      = stdout_expected,
        actual        = m_name + ".exe.stdout",
        timeout       = timeout
    )

    test_program_outputs(
        name    = m_name + ".exe.outputs",
        test_executable = m_name + ".exe",
        stdout = m_name + ".exe.stdout",
        stderr = m_name + ".exe.stderr",
    )

    test_program(
        name    = m_name + ".exe",
        main    = m_name
    )

    test_module(
        name   = m_name,
        struct = structfile,
        sig    = cmi,
        deps   = deps,
        sig_deps    = sig_deps,
        stdlib_deps = stdlib_deps,
        suppress_cmi = suppress_cmi,

        opts   = opts,
        dump   = dump,
        alerts = alerts,
        warnings = warnings,

        # stdout_actual = stdout_actual,
        # stderr_actual = stderr_actual,
        # stdlog_actual = stdlog_actual,
    )

################################################################
## OBSOLETE
#######################
test_vv_executable = rule(
    implementation = _test_program_impl,
    doc = "Links OCaml executable binary using ocamlc.byte",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_vv_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    cfg = vv_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
test_vs_executable = rule(
    implementation = _test_program_impl,
    doc = "Links OCaml executable binary using ocamlopt.byte",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_program" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = vs_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
test_ss_executable = rule(
    implementation = _test_program_impl,
    doc = "Links OCaml executable binary using ocamlopt.opt",
    attrs = dict(
        ##FIXME: remove prologue, epilogue
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_ss_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    cfg = ss_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
test_sv_executable = rule(
    implementation = _test_program_impl,
    doc = "Links OCaml executable binary using ocamlc.opt",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_program" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = sv_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

###############################################################
####  MACRO - generates two exec targets, vm and sys
################################################################
# def test_link_program_macro(name, main,
#                           opts = [],
#                           **kwargs):

#     if main.startswith(":"):
#         main = main[1:]
#     else:
#         main = main

#     test_vv_executable(
#         name    = main + ".vv.byte",
#         main    = main,
#         opts    = opts,
#         tags = ["test_exe"],
#         **kwargs
#     )

#     native.sh_binary(
#         name = main + ".vv.byte.sh",
#         srcs = ["//test/rules:test_link_program.sh"],
#         env  = select({
#             "//test:verbose?": {"VERBOSE": "true"},
#             "//conditions:default": {"VERBOSE": "false"}
#         }),
#         args = ["$(rootpath //runtime:ocamlrun)",
#                 "$(rootpath :{}.vv.byte)".format(main),
#                 # "$(rlocationpath //stdlib:stdlib)"
#                 ],
#         data = [
#             "//runtime:ocamlrun",
#             ":{}.vv.byte".format(main),
#             # "//stdlib",
#             # "//stdlib:Std_exit",
#             # "//config/camlheaders",
#         ],
#         deps = [
#             # for the runfiles lib used in ocamlc.sh:
#             "@bazel_tools//tools/bash/runfiles"
#         ]
#     )

#     test_vs_executable(
#         name    = main + ".vs.opt",
#         main    = main,
#         opts    = opts + OCAML_COMPILER_OPTS,
#         tags    = ["test_exe"],
#         **kwargs
#     )

#     test_ss_executable(
#         name    = main + ".ss.opt",
#         main    = main,
#         opts    = opts + OCAML_COMPILER_OPTS,
#         tags = ["test_exe"],
#         **kwargs
#     )

#     test_sv_executable(
#         name    = main + ".sv.byte",
#         main    = main,
#         opts    = opts,
#         tags    = ["test_exe"],
#         **kwargs
#     )

#     native.sh_binary(
#         name = main + ".sv.byte.sh",
#         srcs = ["//test/rules:test_link_program.sh"],
#         env  = select({
#             "//test:verbose?": {"VERBOSE": "true"},
#             "//conditions:default": {"VERBOSE": "false"}
#         }),
#         args = ["$(rootpath //runtime:ocamlrun)",
#                 "$(rootpath :{}.sv.byte)".format(name),
#                 # "$(rlocationpath //stdlib:stdlib)"
#                 ],
#         data = [
#             "//runtime:ocamlrun",
#             ":{}.sv.byte".format(name),
#             # "//stdlib",
#             # "//stdlib:Std_exit",
#             # "//config/camlheaders",
#         ],
#         deps = [
#             # for the runfiles lib used in ocamlc.sh:
#             "@bazel_tools//tools/bash/runfiles"
#         ]
#     )

