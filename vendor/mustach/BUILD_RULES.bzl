load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

DISABLED_FEATURES = [
    "module_maps",
]

########################
def _mustache_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:mustache"]

    args = ctx.actions.args()
    args.add_all(["-j", ctx.file.json.path])
    args.add_all(["-t", ctx.file.template.path])
    # args.add_all(["-o", outfile.path])
    args.add_all(["-o", ctx.outputs.out.path])

    # for var in ctx.var:
    #     print("VAR: {k}: {v}".format(k=var, v=ctx.var[var]))

    ctx.actions.run(
        mnemonic = "Mustache",
        executable = tc.mustache, ## ctx.file._tool,
        arguments = [args],
        inputs = depset(
            [ctx.file.template, ctx.file.json],
        ),
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
            # cfg = "exec",
        ),
        "template": attr.label(
            mandatory = True,
            allow_single_file = True,
            cfg = "exec",
        ),
        # "_tool": attr.label(
        #     allow_single_file = True,
        #     executable = True,
        #     cfg = "exec",
        #     # cfg = reset_cc_config_transition,
        #     default = "//toolchain/dev:mustach"
        # ),

        # "_target_executor": attr.label(default = "//config/target/executor"),
        # "_target_emitter" : attr.label(default = "//config/target/emitter"),

        # "_cc_toolchain": attr.label(
        #     default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        # ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    },
    cfg = reset_cc_config_transition,
    toolchains = [
        "//toolchain/type:mustache",
        "@bazel_tools//tools/cpp:toolchain_type"
    ]
)
