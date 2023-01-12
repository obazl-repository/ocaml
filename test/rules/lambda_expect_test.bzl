## lambda_expect_test - tests compilation logging, not executable run

load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
# load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load(":test_transitions.bzl",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition")

load("//bzl:providers.bzl", "DumpInfo")

##############################
def _lambda_expect_test_impl(ctx):

    # (this, extension) = paths.split_extension(ctx.file.struct.basename)
    # module_name = this[:1].capitalize() + this[1:]

    # m = module_impl(ctx, module_name)

    # for p in m:
    #     print("RESULT: %s" % p)
    #     if hasattr(p, "struct"):
    #         print("STRUCT: %s" % p)
    #         struct = p.struct
    #         struct_src = p.struct_src
    #         structfile = p.structfile
    #     if hasattr(p, "dump"):
    #         print("LAMBDA: %s" % p)
    #         dlambda = p.dump
    #         break

    runner = ctx.actions.declare_file("lambda_expect_test_runner.sh")
    # lambdafile = ctx.actions.declare_file(struct.path + ".lambda")
    lambdafile = ctx.attr.test_module[DumpInfo].src + ".fixed"
    src_path = "bazel-out/darwin-fastbuild-ST-462396b1cbfe/bin/" + ctx.attr.test_module[DumpInfo].src

    src_path = "bazel-out/darwin-fastbuild-ST-462396b1cbfe/bin/testsuite/tests/basic-modules/bin_vv_vv/anonymous.ml"

    cmd = "\n".join([
        # "echo PWD: $(PWD);",
        # "echo test_module src: {};".format(src_path),
        # "echo STRUCT SRC name: {};".format(struct_src.basename),
        # "echo STRUCTFILE: {};".format(structfile),
        # # "echo STRUCT SRC short path: {}".format(struct_src.short_path),
        # "echo STRUCT path: {};".format(struct.path),
        # # cmd.append("echo STRUCT short path: %s\n" % struct.short_path)
        # "echo DUMP path: {};".format(dlambda.path),
        # "echo LAMBDA path: {};".format(lambdafile),
        # # "echo LAMBDA short path: %s\n" % dlambda.short_path)
        # # "echo EXPECT path: %s\n" % ctx.file.expect.path)
        # # "echo EXPECT short path: %s\n" % ctx.file.expect.short_path)
        # "echo ROOT:   {}".format(dlambda.root.path),
        # # "set -x;",

        # # "echo DUMP: `cat {}`".format(dlambda.short_path),

        # # "sed -e \"s/anonymous/foo/g\" < {dumpfile};".format(
        # #     dumpfile = dlambda.short_path,
        # #     # lambdafile = lambdafile
        # #     ),

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
        # # "echo FIXED: {};".format(lambdafile),
        # # "ls -la;",
        # # "echo END;",

        "diff -wbB {a} {b};".format(
        # a = dlambda.short_path,
        a = lambdafile,
        b = "stripped.expected.txt") # ctx.file.expected.path)
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
    doc = "Test compile logging.",
    attrs = dict(
        # module_attrs(),

        test_module = attr.label(
            allow_single_file = True,
            providers = [DumpInfo]
        ),
        expected = attr.label(
            allow_single_file = True,
        ),

        # _lambda_expect_test = attr.string_list(
        #     default = [
        #         "-nostdlib",
        #         "-nopervasives",
        #         "-dno-unique-ids",
        #         "-dno-locations",
        #         "-dump-into-file",
        #         "-dlambda"
        #     ]
        # ),
        _rule = attr.string( default = "lambda_expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    cfg = vv_test_in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
