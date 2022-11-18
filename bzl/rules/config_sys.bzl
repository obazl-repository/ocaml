# from https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_compile/my_c_compile.bzl

# also https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_archive/my_c_archive.bzl

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

DISABLED_FEATURES = [
    "module_maps",
]

def _config_sys_impl(ctx):

    tc = find_cpp_toolchain(ctx)

    config_map = {}
    for k,v in ctx.var.items():
        print("ctx {k}: {v}".format(k=k, v=v))
        config_map[k] = v

    print("host_path_separator : %s" % ctx.configuration.host_path_separator)
    config_map["host_path_separator"] = ctx.configuration.host_path_separator

    config_map["features"] = ctx.features

    print("genfiles_dir : %s" % ctx.genfiles_dir.path)
    config_map["genfiles_dir"] = ctx.genfiles_dir.path


# AS_CASE([$host],
#   [*-pc-windows],
#     [CC=cl
#     ccomptype=msvc
#     S=asm
#     SO=dll
#     outputexe=-Fe
#     syslib='$(1).lib'],
#   [ccomptype=cc
#   S=s
#   SO=so
#   outputexe='-o '
#   syslib='-l$(1)'])

    if tc.cpu.endswith("x86_64"):
        config_map["arch"] = "amd64"
    if tc.cpu.startswith("darwin"):
        config_map["model"] = "default"
        config_map["system"] = "macosx"

    config_map_json = json.encode_indent(config_map)
    ctx.actions.write(
        output = ctx.outputs.out,
        content = config_map_json
    )

    ########
    return [
        DefaultInfo(files = depset([ctx.outputs.out]))
    ]

####################
config_sys = rule(
    implementation = _config_sys_impl,
    attrs = {
        "out": attr.output(mandatory = True),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
    },
    toolchains = use_cpp_toolchain(),
    fragments = ["cpp", "platform"],
)
