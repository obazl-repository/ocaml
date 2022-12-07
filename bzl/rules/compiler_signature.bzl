load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:signature_impl.bzl", "signature_impl")
load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")

################################################################
def _compiler_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

#######################
compiler_signature = rule(
    implementation = _compiler_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),

        _stdlib_resolver = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",
            default = "//stdlib:Stdlib"
        ),

        _rule = attr.string( default = "compiler_signature" ),
    ),
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
