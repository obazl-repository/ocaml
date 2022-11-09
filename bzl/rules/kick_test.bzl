load("//bzl/rules/common:executable_impl.bzl", "impl_executable")

load("//bzl/rules/common:executable_intf.bzl", "executable_attrs")

##################
kick_test = rule(
    implementation = impl_executable,
    doc = """Bootstrap test rule.
    """,
    attrs = dict(
        executable_attrs(),

        _rule = attr.string( default = "kick_test" ),
    ),
    # cfg = executable_in_transition,
    test = True,
    toolchains = ["//toolchain/type:bootstrap"],
)
