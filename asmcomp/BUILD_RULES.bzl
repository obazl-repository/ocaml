load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

## cvt_emit must be run by ctx.actions.run_shell, so it needs its own
## run rule.  Compare rule run_ocamllex (in lex/BUILD_RULES.bzl)

## Does not use toolchain, pgm is in _tools attribute.

########################
def _run_cvt_emit_impl(ctx):

    debug_bootstrap = False
    debug = True

    print("cvt_emit: %s" % ctx.file._tool)
    print("cvt_emit rfs: %s" % ctx.attr._tool[DefaultInfo].default_runfiles.files)

    print("cvt emit _tool: %s" % ctx.file._tool)

    if ctx.attr._protocol[BuildSettingInfo].value == "dev":
        ## tool tgts are just files w/o runfiles
        ocamlrun = ctx.file._tool
    else:
        ocamlrun = ctx.file._ocamlrun
        # ocamlrun =  ctx.attr._tool[DefaultInfo].default_runfiles.files.to_list()[0]

    executable_cmd = ocamlrun.path + " " + ctx.file._tool.path

    pfx = ctx.label.package

    ctx.actions.run_shell(
        mnemonic = "CvtEmit",
        outputs = [ctx.outputs.out],
        inputs  = [
            ocamlrun,
            ctx.file._tool,
            ctx.file.src
        ],
        # tools attr forces build of these deps:
        tools   = [ocamlrun, ctx.file._tool], # exec_tools,
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
run_cvt_emit = rule(
    implementation = _run_cvt_emit_impl,
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
            default = "//toolchain:cvt_emit"
            # cfg = tool_reset_transition
        ),
        "_ocamlrun" : attr.label(
            allow_single_file = True,
            default = "//toolchain:ocamlrun",
            executable = True,
            cfg = "exec"
            # cfg = reset_cc_config_transition
        ),

        "_protocol" : attr.label(default = "//config/build/protocol"),
        # "_allowlist_function_transition": attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    # toolchains = ["//toolchain/type:boot",
    #               "@bazel_tools//tools/cpp:toolchain_type"]
)
