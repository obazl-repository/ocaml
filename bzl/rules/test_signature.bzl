load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:signature_impl.bzl", "signature_impl")
load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")

################################################################
def _test_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

#######################
test_signature = rule(
    implementation = _test_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),

        _resolver = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",
            default = "//stdlib:Stdlib"
        ),

        _rule = attr.string( default = "test_signature" ),
    ),
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
