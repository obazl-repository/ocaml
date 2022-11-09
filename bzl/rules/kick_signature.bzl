load("//bzl/rules/common:signature_impl.bzl", "impl_signature")
load("//bzl/rules/common:signature_intf.bzl", "signature_attrs")

#######################
boot_signature = rule(
    implementation = impl_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),
        _rule = attr.string( default = "ocaml_signature" ),
    ),
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    toolchains = ["//toolchain/type:bootstrap",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
