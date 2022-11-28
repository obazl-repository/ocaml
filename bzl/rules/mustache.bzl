load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

DISABLED_FEATURES = [
    "module_maps",
]

def _mustache_impl(ctx):

    args = ctx.actions.args()
    args.add_all(["-j", ctx.file.json.path])
    args.add_all(["-t", ctx.file.template.path])
    args.add_all(["-o", ctx.outputs.out.path])

    ctx.actions.run(
        mnemonic = "Mustache",
        executable = ctx.file._tool,
        arguments = [args],
        inputs = depset(
            [ctx.file.template, ctx.file.json],
        ),
        outputs = [ctx.outputs.out],
    )

    ########
    return [
        DefaultInfo(files = depset([ctx.outputs.out]))
    ]

####################
mustache = rule(
    implementation = _mustache_impl,
    attrs = {
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
            cfg = "exec",
            default = "//vendor/mustach"
        ),
        # "_cc_toolchain": attr.label(
        #     default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        # ),
    },
    toolchains = use_cpp_toolchain(),
    # fragments = ["cpp", "platform"],
)
