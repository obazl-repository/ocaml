load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:signature_impl.bzl", "signature_impl")
load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")

######################
def _boot_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

#######################
boot_signature = rule(
    implementation = _boot_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),
        _opts = attr.string_list( ),
        _rule = attr.string( default = "boot_signature" ),
    ),
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
