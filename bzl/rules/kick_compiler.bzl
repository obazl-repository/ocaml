load("//bzl/rules/common:executable_impl.bzl", "impl_executable")
load("//bzl/rules/common:executable_intf.bzl", "executable_attrs")

#####################
boot_compiler = rule(
    implementation = impl_executable,

    doc = "Builds stage 1 ocamlc using stage 0 boot/ocamlc",

    attrs = dict(
        executable_attrs(),

        primitives = attr.label(
            default = "//runtime:primitives", # file produced by genrule
            allow_single_file = True,
            # cfg = boot_compiler_out_transition,
        ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "boot_compiler" ),
    ),
    # cfg = boot_compiler_in_transition,
    executable = True,
    toolchains = ["//toolchain/type:bootstrap"],
)
