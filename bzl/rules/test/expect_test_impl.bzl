load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

## expect_test

## builds an executable and runs it
## executable is expected to write to stdout
## expect_test redirects output to file,
## then diffs it against expected output.

##############################
def expect_test_impl(ctx):

    debug = True

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    if tc.config_executor in ["boot", "baseline", "vm"]:
        ext      = ".byte"
    else:
        ext      = ".opt"

    exe_name = ctx.label.name + ext

    exe = executable_impl(ctx, tc, exe_name, tc.workdir)

    if debug:
        print("exe: %s" % exe)
        print("exe[di]: %s" % exe[0].files)
        # print("exe[di]file to run: %s" % exe[0].files_to_run)
        # for f in exe[0].default_runfiles.files.to_list():
        #     print("RF: %s" % f)
        print("ocamlrun: %s" % tc.ocamlrun)

    pgm = exe[0].files.to_list()[0]

    if tc.config_executor in ["boot", "baseline","vm"]:
        # ocamlrun = exe[0].default_runfiles.files.to_list()[0]
        ocamlrun = tc.ocamlrun
        pgm_cmd = ocamlrun.short_path + " " + pgm.short_path
    else:
        ocamlrun = None
        pgm_cmd = pgm.short_path

    runner = ctx.actions.declare_file(ctx.attr.name + ".sh")
    # stdout = ctx.actions.declare_file(ctx.attr.stdout)
    # print("ROOT: %s" % pgm.short_path)
    # stdout = runner.dirname + "/" + ctx.attr.stdout
    # stdout = ctx.attr.stdout
    stdout = ctx.attr.stdout

    if debug:
        print("tc.name: %s" % tc.name)
        print("ocamlrun: %s" % ocamlrun)
        print("tc.compiler: %s" % tc.compiler)
        # print("tc.lexer: %s" % tc.lexer)
        print("tc.config_executor: %s" % tc.config_executor)
        print("pgm: %s" % pgm)
        print("STDOUT: %s" % stdout)

    cmd = "\n".join([
        # "{pgm} > ${{TEST_TMPDIR}}/{stdout};".format(
        "{pgm} > ${{TEST_UNDECLARED_OUTPUTS_DIR}}/{stdout};".format(
            pgm=pgm_cmd,
            stdout = stdout
        ),
        "diff -w {src} ${{TEST_UNDECLARED_OUTPUTS_DIR}}/{dst}".format(
            src = ctx.file.expect.path,
            dst = stdout
        ),
        "if [ $? -eq 0 ]",
        "then",
        "    echo PASS",
        "else",
        "    echo FAIL",
        "    exit 1",
        "fi",

        # "cp -v ${{TEST_TMPDIR}}/{stdout} ${{TEST_UNDECLARED_OUTPUTS_DIR}}/{stdout};".format(stdout=stdout),
        # "echo SH: %s" % runner.path,
        # "echo STDOUT: %s" % stdout,
        # "echo TEST_TARGET: ${TEST_TARGET}",
        # "echo TEST_SRCDIR: ${TEST_SRCDIR}",
        # "echo TEST_WORKSPACE: ${TEST_WORKSPACE}",
        # "echo TEST_UNDECLARED_OUTPUTS_DIR: ${TEST_UNDECLARED_OUTPUTS_DIR}",
        # "echo TEST_TMPDIR: ${TEST_TMPDIR}",
        # "echo BAZEL_TEST: ${BAZEL_TEST}",
        # "echo PWD: `pwd`;",
        # "echo UNDECL: `ls -l ${TEST_UNDECLARED_OUTPUTS_DIR}`;",
        # "echo STDOUT content: `cat ${{TEST_UNDECLARED_OUTPUTS_DIR}}/{}`;".format(stdout)
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [runner] + [ocamlrun] if ocamlrun else [],
        transitive_files =  depset([
            pgm, ctx.file.expect
        ])
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

    # return expect_impl(ctx, exe_name)

# #######################
# expect_test = rule(
#     implementation = _expect_test_impl,
#     doc = "Compile and test an OCaml program.",
#     attrs = dict(
#         executable_attrs(),

#         stdout = attr.string( ),
#         expect = attr.label(
#             allow_single_file = True,
#         ),

#         _runtime = attr.label(
#             allow_single_file = True,
#             default = "//toolchain:runtime",
#             executable = False,
#             # cfg = reset_cc_config_transition ## only build once
#             # default = "//config/runtime" # label flag set by transition
#         ),

#         _rule = attr.string( default = "expect_test" ),
#         _allowlist_function_transition = attr.label(
#             default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
#         ),
#     ),
#     # cfg = reset_config_transition,
#     # cfg = "exec",
#     cfg = dev_tc_compiler_out_transition,
#     test = True,
#     fragments = ["cpp"],
#     toolchains = ["//toolchain/type:ocaml",
#                   ## //toolchain/type:profile,",
#                   "@bazel_tools//tools/cpp:toolchain_type"]
# )
