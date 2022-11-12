load("//bzl:providers.bzl", "BootInfo", "OcamlArchiveProvider")

load("//bzl/rules/common:archive_intf.bzl", "archive_attrs")
load("//bzl/rules/common:archive_impl.bzl", "impl_archive")

#####################
boot_archive = rule(
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
        _rule = attr.string( default = "boot_archive" ),
    ),
    provides = [OcamlArchiveProvider, BootInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    # toolchains = ["//toolchain/type:boot",
    #               # "//toolchain/type:profile",
    #               "@bazel_tools//tools/cpp:toolchain_type"]
)
