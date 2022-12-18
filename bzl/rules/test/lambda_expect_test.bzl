load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load("//bzl:functions.bzl", "get_workdir")

##############################
def _lambda_expect_test_impl(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    m = module_impl(ctx, module_name)

    for p in m:
        print("RESULT: %s" % p)
        if hasattr(p, "struct"):
            print("STRUCT: %s" % p)
            struct = p.struct
            struct_src = p.struct_src
        if hasattr(p, "dump"):
            print("LAMBDA: %s" % p)
            dlambda = p.dump
            break

    runner = ctx.actions.declare_file("lambda_expect_test_runner.sh")
    # lambdafile = ctx.actions.declare_file(struct.path + ".lambda")
    lambdafile = struct.basename + ".lambda"

    cmd = "\n".join([
        "echo STRUCT SRC path: {};".format(struct_src.path),
        "echo STRUCT SRC name: {};".format(struct_src.basename),
        # "echo STRUCT SRC short path: {}".format(struct_src.short_path),
        "echo STRUCT path: {};".format(struct.path),
        # cmd.append("echo STRUCT short path: %s\n" % struct.short_path)
        "echo DUMP path: {};".format(dlambda.path),
        "echo LAMBDA path: {};".format(lambdafile),
        # "echo LAMBDA short path: %s\n" % dlambda.short_path)
        # "echo EXPECT path: %s\n" % ctx.file.expect.path)
        # "echo EXPECT short path: %s\n" % ctx.file.expect.short_path)
        "echo ROOT:   {}".format(dlambda.root.path),
        # "set -x;",

        # "echo DUMP: `cat {}`".format(dlambda.short_path),

        # "sed -e \"s/anonymous/foo/g\" < {dumpfile};".format(
        #     dumpfile = dlambda.short_path,
        #     # lambdafile = lambdafile
        #     ),

        "sed -e 's|{src}|{name}|g;' {dumpfile} > {lambdafile};".format(
            src    = struct_src.path,
            name   = struct_src.basename,
            dumpfile = dlambda.short_path,
            lambdafile = lambdafile
        ),
        # "echo FIXED: {};".format(lambdafile),
        # "ls -la;",
        # "echo END;",

        "diff -w -B {a} {b};".format(
        # a = dlambda.short_path,
        b = lambdafile,
        a = ctx.file.expect.path)
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [dlambda, ctx.file.expect]
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

    # return lambda_expect_impl(ctx, exe_name)

#######################
lambda_expect_test = rule(
    implementation = _lambda_expect_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        # executable_attrs(),
        struct = attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        sig = attr.label(
            doc = "Single label of a target producing OcamlSignatureProvider (i.e. rule 'ocaml_signature'). Optional.",
            # cfg = compile_mode_out_transition,
            allow_single_file = True, # [".cmi"],
            ## only allow compiled sigs
            # providers = [[OcamlSignatureProvider]],
        ),

        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            # providers = [[OcamlArchiveProvider],
            #              [OcamlLibraryMarker],
            #              [ModuleInfo],
            #              [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),
        _lambda_expect_test = attr.string_list(
            default = [
                "-nostdlib",
                "-nopervasives",
                "-dno-unique-ids",
                "-dno-locations",
                "-dump-into-file",
                "-dlambda"
            ]
        ),
        expect = attr.label(
            allow_single_file = True,
        ),
        opts             = attr.string_list( ),
        nocopts = attr.bool(
            doc = "to disable use toolchain's copts"
        ),
        _verbose = attr.label(default = "//config/ocaml/link:verbose"),
        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

        # _tool    = attr.label(
        #     allow_single_file = True,
        #     default = "//testsuite/tools:inline_expect",
        #     executable = True,
        #     cfg = "exec"
        #     # cfg = reset_cc_config_transition ## only build once
        # ),
        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain/dev:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _stdlib = attr.label(
            doc = "Stdlib",
            default = "//stdlib", # archive, not resolver
            allow_single_file = True, # won't work with boot_library
            # cfg = exe_deps_out_transition,
        ),

        _rule = attr.string( default = "lambda_expect_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    cfg = dev_tc_compiler_out_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
