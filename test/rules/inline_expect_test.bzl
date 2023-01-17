load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

# load(":inline_expect_impl.bzl", "inline_expect_impl")

load("//bzl:providers.bzl",
     "BootInfo", "dump_bootinfo",
)

load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load(":inline_expect_impl.bzl", "inline_expect_test_impl")

load("//bzl/actions:module_compile_action.bzl", "construct_module_compile_action")

################################################################
def cmd_preamble():
    args = []
    args.extend([
        # "set -x",
        # "echo PWD: $(PWD);",
        # "ls -la;",
        # "echo RUNFILES_DIR: $RUNFILES_DIR;",
        "set -uo pipefail; set +e;",
        "f=bazel_tools/tools/bash/runfiles/runfiles.bash ",
        "source \"${RUNFILES_DIR:-/dev/null}/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"${RUNFILES_MANIFEST_FILE:-/dev/null}\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$0.runfiles/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.exe.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    { echo \"ERROR: cannot find $f\"; exit 1; };", ##  f=; set -e; ",
    ])
    # --- end runfiles.bash initialization v2 ---

    args.append("if [ -x ${RUNFILES_DIR+x} ]")
    args.append("then")
    args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
    args.append("else")
    args.append("    echo \"RUNFILES_DIR: ${RUNFILES_DIR}\"")
    args.append("fi")
    args.append("echo STDLIB: $(rlocation ocamlcc/stdlib/bin_ocamlc_byte_ocamlc_byte/Stdlib.cmo)")

################################################################
def _inline_expect_test_impl(ctx):
    debug = True
    debug_ccdeps = True

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

    runner = ctx.actions.declare_file(ctx.attr.name + ".compile.sh")
    cmd_prologue = []
    # if True:  ## ctx.attr.verbose:
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

    cmd = "\n".join([
        "{} \\".format(executor.short_path),
        "{} \\".format(executor_arg.short_path if executor_arg else ""),
        # "-help",
        # # "-verbose \\",
        # "-args \\",
        # "{}".format(args_file.short_path),
        "$(<{}) \\".format(args_file.short_path),
        # "1> \\",
        # "compile.stdout \\",
        # "2>&1 ; \\",
        # "echo RC: $?;"
    ])

    cmd_epilogue = "\n".join([
        # # skip first line containing src file path - non-portable
        # "diff <(tail -n \\+2 {}) <(tail -n \\+2 compile.stdout)".format(
        #     ctx.file.expected.short_path
        # )
    ])

    ctx.actions.write(
        output = runner,
        content = "\n".join(cmd_prologue) + cmd + cmd_epilogue,
        is_executable = True
    )
    ##################
    tc = ctx.toolchains["//toolchain/type:ocaml"]

    runfiles = []
    myrunfiles = ctx.runfiles(
        files = [
            executor,
            args_file,
            ctx.file.struct,
            ctx.file._runfiles_tool
        ] + ([executor_arg] if executor_arg else [])
        + ([ctx.file.expected] if ctx.file.expected else []),

        transitive_files =  depset(
            transitive = []
            + inputs.bootinfo.sigs
            + inputs.bootinfo.structs
            + inputs.bootinfo.cli_link_deps
            # etc.
            + [ctx.attr._runfiles_tool[DefaultInfo].files]
            + [ctx.attr._runfiles_tool[DefaultInfo].default_runfiles.files]
            + [cc_toolchain.all_files] ##FIXME: only for sys outputs
        ),
            # direct=compiler_runfiles,
            # transitive = [depset(
            #     # [ctx.file._std_exit, ctx.file._stdlib]
            # )]
    )

    ################################################################
    defaultInfo = DefaultInfo(
        executable = runner,
        runfiles   = myrunfiles
    )
    providers = [defaultInfo]

    return providers

#######################
inline_expect_test = rule(
    implementation = _inline_expect_test_impl,
    doc = "Compile OCaml inline expect program.",
    attrs = dict(
        # executable_attrs(),
        _tool    = attr.label(
            allow_single_file = True,
            default = "//testsuite/tools:inline_expect",
            executable = True,
            cfg = "exec"
            # cfg = reset_cc_config_transition ## only build once
        ),
        _runfiles_tool = attr.label(
            allow_single_file = True,
            default = "@bazel_tools//tools/bash/runfiles"
        ),

        struct = attr.label(
            # structfile or sigfile?
            mandatory = True,
            allow_single_file = True,
        ),
        sig = attr.label(
            mandatory = False,
            allow_single_file = True,
        ),

        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            # providers = [[OcamlArchiveProvider],
            #              [OcamlLibraryMarker],
            #              [ModuleInfo],
            #              [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),
        cc_deps = attr.label_list(
            providers = [CcInfo],
        ),

        expected = attr.label( #FIXME: not needed?
            allow_single_file = True,
        ),
        opts             = attr.string_list( ),
        nocopts = attr.bool(
            doc = "to disable use toolchain's copts"
        ),

        verbose = attr.bool(),
        _sh_verbose = attr.label(default = "//testsuite/tests:verbose"),
        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _compilerlibs_archived = attr.label( # boolean
            default = "//config/ocaml/compiler/libs:archived"
        ),

        # _stdlib = attr.label(
        #     doc = "Stdlib",
        #     default = "//stdlib", # archive, not resolver
        #     # allow_single_file = True, # won't work with boot_library
        #     # cfg = exe_deps_out_transition,
        # ),

        _rule = attr.string( default = "inline_expect_test" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
