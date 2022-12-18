load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

# rule: cvt_emit runs //tools:cvt_emit.byte

# incoming transition to ensure this is only built once.
# use ctx.actions.expand_template, six times

########################
def _cvt_emit(ctx):

    debug_bootstrap = False
    debug = True

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    exec_tools = [
        tc.executable, ## ocamlrun,
        ctx.file._tool
    ]
    executable_cmd = tc.executable.path + " " + ctx.file._tool.path

    print("EXEC TOOLS: %s" % exec_tools)
    print("exe cmd: %s" % executable_cmd)

    pfx = ctx.label.package

    ctx.actions.run_shell(
        mnemonic = "CvtEmit",
        outputs = [ctx.outputs.out],
        inputs  = [ctx.file.src, tc.executable],
        # tools attr forces build of these deps:
        tools   = exec_tools,
        command = " ".join([
            "echo '# 1 \"{pfx}/emit.mlp\"' > {out};".format(
                pfx=pfx, out = ctx.outputs.out.path),
            # ctx.file._executor.path,
            executable_cmd,
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
            default = ":cvt_emit"
        ),
        # "_allowlist_function_transition": attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
