load("//bzl/rules/common:signature_impl.bzl", "signature_impl")
load("//bzl/rules/common:signature_intf.bzl", "signature_attrs")

#######################
baseline_signature = rule(
    implementation = signature_impl,
    doc = "Sig rule for bootstrapping ocaml compilers",
    exec_groups = {
        "boot": exec_group(
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
        signature_attrs(),

        _stdlib_resolver = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",
            default = "//stdlib:Stdlib"
        ),

        _rule = attr.string( default = "baseline_signature" ),
    ),
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    # toolchains = [
    #     # "//toolchain/type:boot",
    #     "@bazel_tools//tools/cpp:toolchain_type"
    # ]
)
