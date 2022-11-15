load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_intf.bzl", "executable_attrs")

# load("//bzl/rules/common:transitions.bzl", "compiler_in_transition")

#####################
boot_compiler = rule(
    implementation = executable_impl,
    doc = "Builds a compiler",

    exec_groups = {
       "boot": exec_group(
            # exec_compatible_with = [
            #     "//platform/constraints/ocaml/executor:vm",
            #     "//platform/constraints/ocaml/emitter:vm"
            # ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },

    attrs = dict(
        executable_attrs(),

        # only boot_stdlib and boot_compiler have a public 'stage' attr
        # stage = attr.string(
        #     mandatory = True,
        #     values = ["boot", "baseline", "dev", "prod"]
        # ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "boot_compiler" ),
    ),
    # cfg = compiler_in_transition,
    executable = True,
    toolchains = [
        # "//toolchain/type:boot"
        "@bazel_tools//tools/cpp:toolchain_type"
    ],
)
