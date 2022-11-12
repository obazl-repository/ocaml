load("//bzl/rules/common:executable_impl.bzl", "impl_executable")
load("//bzl/rules/common:executable_intf.bzl", "executable_attrs")
load("//bzl/rules/common:transitions.bzl", "compiler_in_transition")

#####################
boot_compiler = rule(
    implementation = impl_executable,
    doc = "Builds a compiler",

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
        # "stdlib": exec_group(
        #     exec_compatible_with = [
        #         "//platforms/ocaml/executor:vm?",
        #         "//platforms/ocaml/emitter:vm?"
        #     ],
        #     toolchains = ["//boot/toolchain/type:stdlib"],
        # ),
    },

    attrs = dict(
        executable_attrs(),

        stage = attr.string(
            mandatory = True,
            values = ["boot", "baseline", "dev"]
        ),

        primitives = attr.label(
            default = "//runtime:primitives", # file produced by genrule
            allow_single_file = True,
            # cfg = boot_compiler_out_transition,
        ),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        _rule = attr.string( default = "boot_compiler" ),
    ),
    cfg = compiler_in_transition,
    executable = True,
    toolchains = [
        # "//toolchain/type:boot"
        "@bazel_tools//tools/cpp:toolchain_type"
    ],
)
