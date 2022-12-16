load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo", "OcamlArchiveProvider")

load("//bzl/attrs:archive_attrs.bzl", "archive_attrs")
load("//bzl/actions:archive_impl.bzl", "archive_impl")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")
load("//bzl/actions:signature_impl.bzl", "signature_impl")

# load("//bzl/transitions:tc_transitions.bzl", "stdlib_in_transition")

# load(":BUILD.bzl", "STDLIB_MANIFEST")


################################################################
def _ns_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    name = this[:1].capitalize() + this[1:]
    ns_pfx = ctx.file.ns.basename[:-4]
    module_name = ns_pfx + "__" + name

    return signature_impl(ctx, module_name)

########################
ns_signature = rule(
    implementation = _ns_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),

        _opts = attr.string_list(
            # default = ["-nostdlib"]  # in tc.copts
        ),

        stdlib_primitives = attr.bool(default = False),
        _stdlib = attr.label(
            default = "//stdlib:Stdlib"
        ),

        _rule = attr.string( default = "ns_signature" ),
    ),
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    # fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _ns_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    name = this[:1].capitalize() + this[1:]
    ns_pfx = ctx.file.ns.basename[:-4]
    module_name = ns_pfx + "__" + name

    return module_impl(ctx, module_name)

#######################
ns_module = rule(
    implementation = _ns_module,
    doc = "Compiles a module with the bootstrap compiler.",
    attrs = dict(
        module_attrs(),

        stdlib_primitives = attr.bool(default = False),
        _stdlib = attr.label(
            default = "//stdlib:Stdlib"
        ),
        # _opts = attr.string_list(
        #     default = ["-open", "Dynlink_compilerlibs"],
        # ),

        # _resolver = attr.label(
        #     default = "//otherlibs/dynlink:Dynlink_compilerlibs"
        # ),

        _rule = attr.string( default = "ns_module" ),
    ),
    # cfg = compile_mode_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
