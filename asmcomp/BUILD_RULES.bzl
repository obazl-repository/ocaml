load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/rules/common:transitions.bzl", "reset_config_transition")

# incoming transition to ensure this is only built once.
# use ctx.actions.expand_template, six times

########################
def _cvt_emit(ctx):

    debug_bootstrap = False

    # tc = ctx.toolchains["//toolchain/type:boot"]

    # target_executor = tc.target_executor[BuildSettingInfo].value
    # target_emitter  = tc.target_emitter[BuildSettingInfo].value
    # stage = tc._stage[BuildSettingInfo].value

    # workdir = "_{b}{t}{stage}/".format(
    #     b = target_executor, t = target_emitter, stage = stage)

    # outfile = ctx.actions.declare_file(workdir + "emit.ml")

    pfx = ctx.label.package

    # args = ctx.actions.args()
    # args.add(ctx.file._tool)
    # args.add_all([">", ctx.outputs.out.path])

    ## FIXME: don't use ocamlrun to run a sys executable!

    ctx.actions.run_shell(
        mnemonic = "CvtEmit",
        outputs = [ctx.outputs.out],
        inputs  = [ctx.file.src],
        # tools attr forces build of these deps:
        tools   = [ctx.file._executor, ctx.file._tool],
        command = " ".join([
            "echo '# 1 \"{pfx}/emit.mlp\"' > {out};".format(
                pfx=pfx, out = ctx.outputs.out.path),
            ctx.file._executor.path,
            ctx.file._tool.path,
            "<",
            ctx.file.src.path,
            ">>",
            ctx.outputs.out.path
        ])
    )

    defaultInfo = DefaultInfo(
        files=depset(direct = [ctx.outputs.out]),
    )
    return defaultInfo

#####################
cvt_emit = rule(
    implementation = _cvt_emit,
    doc = "Preprocess .mlp files",
    attrs = {
        "src"   : attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        "out"  : attr.output(
            mandatory = True,
        ),
        "_tool" : attr.label(
            allow_single_file=True,
            default = "//tools:cvt_emit.byte"
        ),
        "_executor": attr.label(
            allow_single_file = True,
            default = "//runtime:ocamlrun",
            executable = True,
            cfg = reset_config_transition,
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:boot",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
