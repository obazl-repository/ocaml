load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

DISABLED_FEATURES = [
    "module_maps",
]

########################
def _mustache_impl(ctx):

    # target_executor = ctx.attr._target_executor[BuildSettingInfo].value
    # target_emitter = ctx.attr._target_emitter[BuildSettingInfo].value

    ##FIXME: do not prepend workdir for C outputs

    # if ctx.attr.out.endswith(".h"):
    #     workdir = ""
    # elif ctx.attr.out.endswith(".c"):
    #     workdir = ""
    # elif (target_executor == "boot"):
    #     workdir = "_boot/"
    # elif (target_executor == "vm" and target_emitter == "vm"):
    #     workdir = "_ocamlc.byte/"
    # elif (target_executor == "vm" and target_emitter == "sys"):
    #     workdir = "_ocamlopt.byte/"
    # elif (target_executor == "sys" and target_emitter == "sys"):
    #     workdir = "_ocamlopt.opt/"
    # elif (target_executor == "sys" and target_emitter == "vm"):
    #     workdir = "_ocamlc.opt/"

    # workdir = "" # _tools/"

    # outfile = ctx.actions.declare_file(workdir + ctx.attr.out)

    args = ctx.actions.args()
    args.add_all(["-j", ctx.file.json.path])
    args.add_all(["-t", ctx.file.template.path])
    # args.add_all(["-o", outfile.path])
    args.add_all(["-o", ctx.outputs.out.path])

    ctx.actions.run(
        mnemonic = "Mustache",
        executable = ctx.file._tool,
        arguments = [args],
        inputs = depset(
            [ctx.file.template, ctx.file.json],
        ),
        # outputs = [outfile]
        outputs = [ctx.outputs.out],
    )

    ########
    return [
        # DefaultInfo(files = depset([outfile]))
        DefaultInfo(files = depset([ctx.outputs.out]))
    ]

####################
mustache = rule(
    implementation = _mustache_impl,
    attrs = {
        # "out": attr.string(mandatory = True),
        "out": attr.output(mandatory = True),
        "json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "template": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "_tool": attr.label(
            allow_single_file = True,
            executable = True,
            # cfg = "exec",
            cfg = reset_cc_config_transition,
            default = "//vendor/mustach"
        ),

        # "_target_executor": attr.label(default = "//config/target/executor"),
        # "_target_emitter" : attr.label(default = "//config/target/emitter"),

        # "_cc_toolchain": attr.label(
        #     default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        # ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    },
    # toolchains = [
    #     # "//toolchain/type:boot",
    #     "@bazel_tools//tools/cpp:toolchain_type"
    # ]
)
