## lambda_expect_test - tests compilation logging, not executable run

load(":test_transitions.bzl",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition")

load("//bzl:providers.bzl", "DumpInfo")

##############################
def _lambda_expect_test_impl(ctx):

    runner = ctx.actions.declare_file("lambda_expect_test_runner.sh")
    lambdafile = ctx.attr.test_module[DumpInfo].src + ".fixed"
    src_path = ctx.attr.test_module[DumpInfo].src

    ##FIXME: need to use runfiles bash lib to get the path
    src_path = "bazel-out/darwin-fastbuild-ST-462396b1cbfe/bin/testsuite/tests/basic-modules/bin_vv_vv/anonymous.ml"

    cmd = "\n".join([
        ## strip newlines from both files, then sed the actual to
        ## remove paths, then compare, ignoring spaces
        ## assumption: whitespace is insignificant

        "cat {} | tr -d '\n' > stripped.expected.txt".format(
            ctx.file.expected.path),
        "cat {} | tr -d '\n' > stripped.txt".format(
            ctx.attr.test_module[DumpInfo].dump.short_path),

        "sed -e 's|{src}|{name}|g;' {dumpfile} > {lambdafile};".format(
            src    = src_path,
            name   = "anonymous.ml",
            dumpfile = "stripped.txt",
            lambdafile = lambdafile
        ),

        "diff -wbB {a} {b};".format(
        a = lambdafile,
        b = "stripped.expected.txt")
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [ctx.attr.test_module[DumpInfo].dump, ctx.file.expected]
        # transitive_files =  depset(
        #     transitive = [
        #         depset(direct=runfiles),
        #         sigs_depset
        #     ]
        # )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

#######################
lambda_expect_test = rule(
    implementation = _lambda_expect_test_impl,
    doc = "Compilation log diffing.",
    attrs = dict(

        test_module = attr.label(
            allow_single_file = True,
            providers = [DumpInfo]
        ),
        expected = attr.label(
            allow_single_file = True,
        ),

        _rule = attr.string( default = "lambda_expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = vv_test_in_transition,
    test = True,
)
