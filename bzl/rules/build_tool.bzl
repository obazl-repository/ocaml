load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/rules/common:transitions.bzl", "executable_in_transition")

########################
# def _build_tool(ctx):

#     tc = ctx.toolchains["//toolchain/type:boot"]
#     return impl_executable(ctx, tc)

#######################
build_tool = rule(
    implementation = executable_impl,
    doc = "Links OCaml executable binary using the bootstrap toolchain",

    exec_groups = {
        "boot": exec_group(
            # exec_compatible_with = [
            #     "//platform/constraints/ocaml/executor:vm?",
            #     "//platform/constraints/ocaml/emitter:vm"
            # ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm?",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },

    attrs = dict(
        executable_attrs(),

        # stage = attr.label(default = "//config/stage"),

        _rule = attr.string( default = "build_tool" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = executable_in_transition,
    executable = True,
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type"
    ],
)
