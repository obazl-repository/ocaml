load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl:providers.bzl", "HybridExecutableMarker")

## expect_test

## builds an executable and runs it
## executable is expected to write to stdout
## expect_test redirects output to file,
## then diffs it against expected output.

##############################
def batch_test_impl(ctx):

    debug = False

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    # if tc.config_executor in ["boot", "baseline", "vm"]:
    #     ext      = ".byte"
    # else:
    #     ext      = ".opt"

    # exe_name = ctx.label.name + ext

    ## FIXME: ocamltest diffs both the compiler stderr/stdout, and the
    ## stdout/stderr of the compiled test case executable.

    ## currently we call executable_impl to build the executable,
    ## without checking the link stdout/stderr, then below we run the
    ## executable and diff its output. to match ocamltest, we need a
    ## test_executable_impl that does what executable_impl does but
    ## checks its stdout/stderr.

    ## see compiler_fail_test.bzl for starters

    # exe = executable_impl(ctx, tc, exe_name, tc.workdir)
    # pgm = exe[0].files.to_list()[0]
    pgm = ctx.file.test_executable

    if debug:
        print("pgm: %s" % pgm)
        if HybridExecutableMarker in ctx.attr.test_executable:
            print("hybrid!")
        print("tc.config_executor: %s" % tc.config_executor)
        print("tc.config_emitter: %s" % tc.config_emitter)

        print("exe file to run: %s" % ctx.attr.test_executable.files_to_run.executable)
        # for f in exe[0].default_runfiles.files.to_list():
        #     print("RF: %s" % f)
        print("OCAMLRUN: %s" % tc.ocamlrun)

    if tc.config_executor in ["boot", "baseline","vm"]:
        if tc.config_emitter == "sys":
            ocamlrun = None
            ocamlrun_path = ""
            pgm_cmd = pgm.short_path
        else:
            if HybridExecutableMarker in ctx.attr.test_executable:
                ocamlrun_path = ""
                pgm_cmd = pgm.short_path
            else:
                ocamlrun_path = tc.ocamlrun.short_path
                pgm_cmd = tc.ocamlrun.short_path + " ocamlcc/" + pgm.short_path
    else:
        if tc.config_emitter == "sys":
            ocamlrun = None
            ocamlrun_path = ""
            pgm_cmd = pgm.short_path
        else:
            ocamlrun_path = tc.ocamlrun.short_path
            pgm_cmd = tc.ocamlrun.short_path + " ocamlcc/" + pgm.short_path
        # ocamlrun = None
        # ocamlrun_path = ""
        # pgm_cmd = pgm.short_path

    runner = ctx.actions.declare_file(ctx.attr.name + ".sh")
    stdout = ctx.attr.stdout_actual

    if debug:
        print("tc.name: %s" % tc.name)
        print("tc.config_executor: %s" % tc.config_executor)
        print("tc.compiler: %s" % tc.compiler)
        print("pgm: %s" % pgm)
        print("ocamlrun: %s" % tc.ocamlrun)
        print("pgm_cmd: %s" % pgm_cmd)
        print("STDOUT: %s" % stdout)

    cmd = "\n".join([
        "{ocamlrun} {pgm} {redir} ${{TEST_UNDECLARED_OUTPUTS_DIR}}/{stdout};".format(
            ocamlrun = ocamlrun_path,
            redir = ">",
            pgm      = pgm.short_path,
            stdout = stdout
        ),

        ## FIXME: split 'diff' action into separate rule???
        "diff {diffargs} {src} ${{TEST_UNDECLARED_OUTPUTS_DIR}}/{dst}".format(
            diffargs = " ".join(ctx.attr.diff_args),
            src = ctx.file.stdout_expected.path,
            dst = stdout
        ),

        # "RC=$?;",
        # "if [ $RC -eq 0 ]",
        # "then",
        # # "    echo PASS",
        # "    :",
        # "else",
        # # "    echo FAIL;",
        # "    exit $RC",
        # "fi",

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
        files = [runner, pgm],
        transitive_files =  depset([
            ctx.file.stdout_expected
            ] + [tc.ocamlrun] if tc.ocamlrun else [],
        )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]
