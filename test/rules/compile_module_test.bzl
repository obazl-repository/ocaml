load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "BootInfo", "dump_bootinfo",
     "DumpInfo", "ModuleInfo", "NsResolverInfo",
     "DepsAggregator",
     "StdLibMarker",
     "StdStructMarker",
     "StdlibStructMarker",
     "new_deps_aggregator", "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name") #, "get_workdir")
load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")
load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:impl_ccdeps.bzl", "dump_CcInfo", "ccinfo_to_string")
load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")
load("//bzl/attrs:module_attrs.bzl", "module_attrs")

load("//bzl/actions:module_compile_action.bzl", "construct_module_compile_action")

# load(":compile_module_test_impl", "compile_module_test_impl")

cmd_runfiles = [
    # "echo PATH: $(echo $PATH);",
    # # --- begin runfiles.bash initialization v2 ---
    # "set -uo pipefail;",
    # "set +e;",
    # "set -x;",
    # #"f=tools/bash/runfiles/runfiles.bash;",
    # #"f=bazel_tools/tools/bash/runfiles/runfiles.bash;",
    # "f=external/bazel_tools/tools/bash/runfiles/runfiles.bash;",
    # # "echo F: `cat $f`;"
    # # "f={};".format(ctx.file._runfiles_tool.short_path),
    # # "source \"${RUNFILES_DIR:-/dev/null}/$f\" 2>/dev/null; ",

        # "source \"${RUNFILES_DIR:-/dev/null}/$f\" 2>/dev/null || \\ ",
    # "source \"$(grep -sm1 \"^$f \" \"${RUNFILES_MANIFEST_FILE:-/dev/null}\" | cut -f2- -d' ')\" 2>/dev/null;", ##  || \\ ",

        # # "source \"$0.runfiles/$f\" 2>/dev/null || \\ ",
    # # "source \"$(grep -sm1 \"^$f \" \"$0.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\ ",
    # # "source \"$(grep -sm1 \"^$f \" \"$0.exe.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\ ",
    # # "{ echo>&2 \"ERROR: cannot find $f\"; exit 1; }; f=; set -e ",
    # # # --- end runfiles.bash initialization v2 ---

        # "echo \"MANIFEST: ${RUNFILES_DIR}\"; ",
    # "echo \"`ls ${RUNFILES_DIR}`\"; ",

        # # "$(rlocation ocamlcc/config/camlheaders/camlheader)"

        # # "echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"; ",
    # # "echo \"`cat ${RUNFILES_MANIFEST_FILE}`\"; "
]

################################################################
def _this_impl(ctx):
    debug = True
    debug_ccdeps = False

    if ctx.label.name == "Load_path":
        debug = True

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    (inputs,
     outputs, # dictionary of files
     executor,
     executor_arg,
     workdir,
     cmd_args) = construct_module_compile_action(ctx, module_name)

    if debug:
        print("compiling module: %s" % ctx.label)
        print("INPUT BOOTINFO:")
        dump_bootinfo(inputs.bootinfo)
        print("OUTPUTS: %s" % outputs)
        print("INPUT FILES: %s" % inputs.files)
        print("INPUT.structfile: %s" % inputs.structfile)
        print("INPUT.cmi: %s" % inputs.cmi)

        print("CMD ARGS: %s" % cmd_args)
        print("EXECUTOR: %s" % executor)
        print("EXECUTOR ARG: %s" % executor_arg)

        # fail()

    # if ctx.label.name == "Bytesections":
    #     fail()

    outs = []
    for v in outputs.values():
        if v: outs.append(v)

    cc_toolchain = find_cpp_toolchain(ctx)

    ################
    # PROBLEM: normally we symlink src files to workdir, compile, and
    # add symlink srcs to provider. But this doesn't work when we
    # drive the compile from a shell script. The problem is that the
    # symlinks do not transfer - we write the shell script, then Bazel
    # runs it _after_ this target has finished, so the links are no
    # longer there. In an ordinary compile they're retained because we
    # emit them in a provider.

    # Here we add them to runfiles, but they do not show up in the
    # sandbox. We add the symlink path to the cmd link with -I, but
    # symlinked file is not there. Evidently only symlinks whose
    # targets were created are retained.

    ##################
    args_file = ctx.actions.declare_file(ctx.attr.name + ".compile.args")
    ctx.actions.write(
        output = args_file,
        content = cmd_args,
        is_executable = True
    )

    # runner = ctx.actions.declare_file(ctx.attr.name + ".compile.sh")

    cmd_prologue = [
    "set -uo pipefail;",
    "set +e;",
    ]
    if (ctx.attr.verbose
        or ctx.attr._sh_verbose[BuildSettingInfo].value):
        cmd_prologue.append("echo PWD: $(PWD);")
        cmd_prologue.append("set -x;")

    if hasattr(ctx.attr, "suppress_cmi"):
        suppressed_cmis = []
        for dep in ctx.attr.suppress_cmi:
            suppressed_cmis.extend(dep[BootInfo].sigs.to_list())
        for cmi in suppressed_cmis:
            cmd_prologue.append("rm -f {}; ".format(cmi.short_path))
    cmd_prologue.append("")

    if ctx.file.stdout_actual:
        stdout_actual = ctx.actions.declare_file(ctx.file.stdout_actual.path)
    else:
        stdout_actual = ctx.actions.declare_file(ctx.file.struct.basename + ".stdout")

    # if ctx.file.stderr_actual:
    #     stderr_actual = ctx.actions.declare_file(ctx.file.stderr_actual.basename)
    # else:
    #     stderr_actual = ctx.actions.declare_file(ctx.file.struct.basename + ".stderr")

    cmd = "\n".join([
        "{} \\".format(executor.path),
        "{} \\".format(executor_arg.path if executor_arg else ""),
        # "-help \\",
        # "-verbose \\",
        "-args \\",
        "{} \\".format(args_file.path),
        # "1> \\",
        # "{} \\".format(stdout_actual.short_path),
        # "2> \\",
        # "{} ; ".format(ctx.outputs.stderr_actual.short_path),
        # "RC=$?;",
        # "if [ $RC == \"{rc}\" ]".format(rc=ctx.attr.rc_expected),
        # "then",
        # "    exit 0",
        # "else",
        # "    exit $RC",
        # "fi"
    ])

    # cmd_epilogue = "\n".join([
    #     # skip first line containing src file path - non-portable
    #     "diff <(tail -n \\+2 {actual}) <(tail -n \\+2 {expected})".format(
    #         actual=ctx.file.stdout_expected.short_path,
    #         expected=ctx.file.stdout_actual.short_path
    #     )
    # ])

    cmd = " ".join(cmd_prologue) + cmd ##  + cmd_epilogue,
    print("CMD: %s" % cmd)

    ctx.actions.run_shell(
        inputs = depset(
            direct = [executor, executor_arg,
                      ctx.file.struct, ctx.file.stderr_expected,
                      args_file],
            transitive = []
            + inputs.bootinfo.sigs
            + inputs.bootinfo.structs
            + inputs.bootinfo.cli_link_deps
        ),
        # outputs = outs,
        outputs = [stdout_actual, ctx.outputs.stderr_actual],
        tools = [executor, executor_arg],
        # arguments = [args],
        command = cmd
    )

    # ctx.actions.write(
    #     output = runner,
    #     # content = cmd,
    #     content = "\n".join(cmd_prologue) + cmd, ##  + cmd_epilogue,
    #     is_executable = True
    # )

    # ctx.actions.write(
    #     output = ctx.outputs.stdout_actual,
    #     content = "",
    #     is_executable = False
    # )
    ##################
    tc = ctx.toolchains["//toolchain/type:ocaml"]

    # runfiles = []
    # myrunfiles = ctx.runfiles(
    #     files = [
    #         executor,
    #         args_file,
    #         ctx.file.struct,
    #         # ctx.file.stdout_actual,
    #         # ctx.file.stdout_expected,
    #         ctx.file.stderr_expected,
    #         ctx.file._runfiles_tool
    #     ] + ([executor_arg] if executor_arg else []),
    #     transitive_files =  depset(
    #         transitive = []
    #         + inputs.bootinfo.sigs
    #         + inputs.bootinfo.structs
    #         + inputs.bootinfo.cli_link_deps
    #         # etc.
    #         + [ctx.attr._runfiles_tool[DefaultInfo].files]
    #         + [ctx.attr._runfiles_tool[DefaultInfo].default_runfiles.files]
    #         + [cc_toolchain.all_files] ##FIXME: only for sys outputs
    #     ),
    #         # direct=compiler_runfiles,
    #         # transitive = [depset(
    #         #     # [ctx.file._std_exit, ctx.file._stdlib]
    #         # )]
    # )

    # print("BASH %s" % ctx.file._runfiles_tool.path)

    ################################################################
    defaultInfo = DefaultInfo(
        files = depset([ctx.outputs.stderr_actual])
        ## FIXME: plus cmo/cmx if expected RC == 0

        # executable = runner,
        # runfiles   = myrunfiles
    )
    providers = [defaultInfo]

    return providers

################################################################
compile_module_testx = rule(
    implementation = _this_impl,
    doc = "Compiles a module.",
    attrs = dict(
        module_attrs(),
        verbose = attr.bool(),
        _sh_verbose = attr.label(default = "//testsuite/tests:verbose"),
        suppress_cmi = attr.label_list(
            doc = "For testing only: do not pass on cmi files in Providers.",
            providers = [
                [ModuleInfo],
                [StdLibMarker],
            ],
        ),
        rc_expected = attr.int(),
        stdout_actual = attr.label(
            # mandatory = True,
            allow_single_file = True,
        ),
        stdout_expected = attr.label(
            # mandatory = True,
            allow_single_file = True
        ),

        stderr_actual = attr.output(
            # mandatory = True,
            # allow_single_file = True,
        ),
        stderr_expected = attr.label(
            # mandatory = True,
            allow_single_file = True
        ),

        # stdlib_primitives = attr.bool(default = True),
        # _stdlib = attr.label(
        #     doc = "The commpiler always opens Stdlib, so everything depends on it.",

        #     default = "//stdlib"
        # ),
        _runfiles_tool = attr.label(
            allow_single_file = True,
            default = "@bazel_tools//tools/bash/runfiles"
        ),
        _rule = attr.string( default = "compile_module_test" ),
    ),
    # cfg = compile_mode_in_transition,
    # test = True,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
