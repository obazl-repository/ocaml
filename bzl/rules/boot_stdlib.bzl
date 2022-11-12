load("//bzl:providers.bzl", "BootInfo", "OcamlArchiveProvider")

load("//bzl/rules/common:archive_intf.bzl", "archive_attrs")
load("//bzl/rules/common:archive_impl.bzl", "impl_archive")
load("//bzl/rules/common:transitions.bzl", "stdlib_in_transition")

#####################
boot_stdlib = rule(
    implementation = impl_archive,
    doc = """Generates an OCaml archive file using the bootstrap toolchain.""",
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
        archive_attrs(),

        stage = attr.string(
            mandatory = False,
            values = ["boot", "baseline", "dev"]
        ),
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
