load("//bzl:providers.bzl", "BootInfo", "OcamlArchiveProvider")

load("//bzl/attrs:archive_attrs.bzl", "archive_attrs")
load("//bzl/actions:archive_impl.bzl", "archive_impl")

load("//bzl/rules/common:transitions.bzl", "stdlib_in_transition")

#####################
boot_stdlib = rule(
    implementation = archive_impl,
    doc = """Generates an OCaml archive file using the bootstrap toolchain.""",
    exec_groups = {
        "boot": exec_group(
            exec_compatible_with = [
                "//platform/constraints/ocaml/executor:vm?",
                "//platform/constraints/ocaml/emitter:vm"
            ],
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
        archive_attrs(),

        # only boot_stdlib and boot_compiler have a public 'stage' attr
        stage = attr.label( default = "//bzl:stage" ),

        _rule = attr.string( default = "boot_stdlib" ),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    provides = [OcamlArchiveProvider, BootInfo],
    cfg = stdlib_in_transition,
    executable = False,
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    # toolchains = ["//toolchain/type:boot",
    #               # "//toolchain/type:profile",
    #               "@bazel_tools//tools/cpp:toolchain_type"]
)
