load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/actions:module_impl.bzl", "module_impl")
# load("//bzl/actions:expect_impl.bzl", "expect_impl")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load("//bzl:providers.bzl", "ModuleInfo", "SigInfo")

load("//bzl:functions.bzl", "get_workdir")

##############################
def _run_tool_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)

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
    doc = "Compile and test an OCaml program.",
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
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    executable = True,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
