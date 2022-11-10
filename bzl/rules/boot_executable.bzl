load("//bzl/rules/common:executable_impl.bzl", "impl_executable")
load("//bzl/rules/common:executable_intf.bzl", "executable_attrs")

########################
def _boot_executable(ctx):

    tc = ctx.toolchains["//toolchain/type:bootstrap"]
    return impl_executable(ctx, tc)

#######################
boot_executable = rule(
    implementation = _boot_executable,
    doc = "Links OCaml executable binary using the bootstrap toolchain",
    attrs = dict(
        executable_attrs(),

        _rule = attr.string( default = "boot_executable" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    toolchains = ["//toolchain/type:bootstrap"],
)
