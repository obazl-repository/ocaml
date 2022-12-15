load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:signature_impl.bzl", "signature_impl")
load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")

################################################################
def _tool_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

#######################
tool_signature = rule(
    implementation = _tool_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),
        stdlib_primitives = attr.bool(
            # FIXME: does False mean -nopervasives?
            doc = "Should be True only if -nopervasives does not work",
            default = False
        ),
        _stdlib = attr.label(
            ## only added to depgraph if stdlib_primitives == True
            allow_single_file = True,
            default = "//stdlib:Stdlib"
        ),

        _rule = attr.string( default = "tool_signature" ),
    ),
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
