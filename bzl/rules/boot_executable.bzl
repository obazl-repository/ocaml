load("//bzl/rules/common:executable_impl.bzl", "impl_executable")
load("//bzl/rules/common:executable_intf.bzl", "executable_attrs")
# load("//bzl/rules/common:transitions.bzl", "executable_in_transition")

########################
# def _boot_executable(ctx):

#     tc = ctx.toolchains["//toolchain/type:boot"]
#     return impl_executable(ctx, tc)

#######################
boot_executable = rule(
    implementation = impl_executable, ##_boot_executable,
    doc = "Links OCaml executable binary using the bootstrap toolchain",

    exec_groups = {
        "boot": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        "baseline": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:baseline"],
        ),
    },

    attrs = dict(
        executable_attrs(),

        _rule = attr.string( default = "boot_executable" ),
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
