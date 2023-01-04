load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "ModuleInfo", "SigInfo")

##############################
def _run_tool_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    runner = ctx.actions.declare_file(ctx.attr.name + ".sh")

    print("ARG %s" % ctx.attr.arg)
    # tgt = ctx.expand_location(
    #     "$(location {})".format(ctx.attr.arg))
    #     # [ctx.attr.arg])
    tgt = ctx.file.arg
    print("TGT %s" % tgt)

    if tgt.basename == "BUILD.bazel":
        # no --//:arg passed
        arg = ""

    if ctx.label.name == "ocamlcmt":
        if ModuleInfo in ctx.attr.arg:
            arg = ctx.attr.arg[ModuleInfo].cmt.short_path
        elif SigInfo in ctx.attr.arg:
            arg = ctx.attr.arg[SigInfo].cmti.short_path
    else:
        arg = ctx.file.arg.short_path

    cmt_files = []
    if ModuleInfo in ctx.attr.arg:
        cmt_files.append(ctx.attr.arg[ModuleInfo].cmt)
    if SigInfo in ctx.attr.arg:
        cmt_files.append(ctx.attr.arg[SigInfo].cmti)

    if ctx.attr._verbose[BuildSettingInfo].value:
        verbose = "set -x"
    else:
        verbose = ""

    cmd = "\n".join([
        # "echo ARGS: $@;",
        verbose,
        "{pgm} $@ {arg};\n".format(
            pgm = ctx.file.tool.short_path,
            arg = arg)
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [
            ctx.file.tool, ctx.file.arg
        ],
        transitive_files =  depset(
            transitive = [
                ctx.attr.tool[DefaultInfo].default_runfiles.files,
                depset(cmt_files)
            ]
        )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

    # return expect_impl(ctx, exe_name)

#######################
run_tool = rule(
    implementation = _run_tool_impl,
    doc = "Run an ocaml tool.",
    attrs = dict(
        tool = attr.label(
            allow_single_file = True,
        ),
        arg = attr.label(
            allow_single_file = True,
            default = "//:arg"
        ),
        _verbose = attr.label(
            default = "//:verbose"
        ),

        _rule = attr.string( default = "run_tool" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##############################
def _run_ocamldep_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    runner = ctx.actions.declare_file(ctx.attr.name + ".runner")

    ## NB: Bazel sets env var BUILD_WORKSPACE_DIRECTORY when you
    ## `bazel run`; this is needed since the execution (launch) dir is
    ## somewhere in Bazel's private area (run with --//tools:verbose
    ## to see this). So this gets us the src directories relative to
    ## the project root:
    includes = " ".join([
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/stdlib",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/utils",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/parsing",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/typing",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/asmcomp",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/bytecomp",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/middle_end",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/middle_end/closure",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/middle_end/flambda",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/middle_end/flambda/base_types",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/driver",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/toplevel",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/file_formats",
        "-I", "${BUILD_WORKSPACE_DIRECTORY}/lambda",
    ])

    if ctx.attr._verbose[BuildSettingInfo].value:
        verbose = "echo PWD: $PWD; set -x;"
    else:
        verbose = ""

    cmd = "\n".join([
        # "echo ARGS: $@;",
        verbose,
        "{pgm} {incs} $@ {arg};\n".format(
            pgm = ctx.file.tool.short_path,
            incs = includes,
            arg = ctx.file.arg.path)
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [
            ctx.file.tool, ctx.file.arg
        ],
        transitive_files =  depset(
            transitive = [
                ctx.attr.tool[DefaultInfo].default_runfiles.files,
            ]
        )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

    # return expect_impl(ctx, exe_name)

#######################
run_ocamldep = rule(
    implementation = _run_ocamldep_impl,
    doc = "Run ocamldep tool.",
    attrs = dict(
        tool = attr.label(
            allow_single_file = True,
        ),
        arg = attr.label(
            # mandatory = True,
            allow_single_file = True,
            default = "//tools:arg"
        ),
        _verbose = attr.label(
            default = "//tools:verbose"
        ),

        _rule = attr.string( default = "run_ocamldep" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
##############################
def _run_ocamlcmt_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    runner = ctx.actions.declare_file(ctx.attr.name)

    print("ARG %s" % ctx.attr.arg)
    # tgt = ctx.expand_location(
    #     "$(location {})".format(ctx.attr.arg))
    #     # [ctx.attr.arg])
    tgt = ctx.file.arg
    print("TGT %s" % tgt)

    # if tgt.basename == "BUILD.bazel":
    #     # no --//:arg passed
    #     arg = ""

    if ctx.label.name == "ocamlcmt":
        if ModuleInfo in ctx.attr.arg:
            arg = ctx.attr.arg[ModuleInfo].cmt.short_path
        elif SigInfo in ctx.attr.arg:
            arg = ctx.attr.arg[SigInfo].cmti.short_path
    else:
        arg = ctx.file.arg.short_path

    cmt_files = []
    if ModuleInfo in ctx.attr.arg:
        cmt_files.append(ctx.attr.arg[ModuleInfo].cmt)
    if SigInfo in ctx.attr.arg:
        cmt_files.append(ctx.attr.arg[SigInfo].cmti)

    if ctx.attr._verbose[BuildSettingInfo].value:
        verbose = "set -x"
    else:
        verbose = ""

    cmd = "\n".join([
        # "echo ARGS: $@;",
        verbose,
        "{pgm} $@ {arg};\n".format(
            pgm = ctx.file.tool.short_path,
            arg = arg)
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [
            ctx.file.tool, ctx.file.arg
        ],
        transitive_files =  depset(
            transitive = [
                ctx.attr.tool[DefaultInfo].default_runfiles.files,
                depset(cmt_files)
            ]
        )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

    # return expect_impl(ctx, exe_name)

#######################
run_ocamlcmt = rule(
    implementation = _run_ocamlcmt_impl,
    doc = "Run ocamlcmt tool.",
    attrs = dict(
        tool = attr.label(
            allow_single_file = True,
        ),
        includes = attr.label_list(
            default = [
                "//asmcomp",
                "//bytecomp",
                "//stdlib"
            ]
        ),
        arg = attr.label(
            mandatory = True,
            allow_single_file = True,
            default = "//tools:arg"
        ),
        _verbose = attr.label(
            default = "//tools:verbose"
        ),

        _rule = attr.string( default = "run_ocamlcmt" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
