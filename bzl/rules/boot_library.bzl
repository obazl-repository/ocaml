load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "ModuleInfo",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlSignatureProvider")

# load(":options.bzl", "options", "options_library")

# load("//bzl/transitions:manifest.bzl",
#      "manifest_out_transition")

load(":impl_library.bzl", "impl_library")

###############################
def _boot_library(ctx):

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    ##mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    return impl_library(ctx)

###############################
# rule_options = options("ocaml")
# rule_options.update(options_library("ocaml"))

#####################
boot_library = rule(
    implementation = impl_library, ## _boot_library,
    doc = """Aggregates a collection of OCaml modules. [User Guide](../ug/boot_library.md). Provides: [OcamlLibraryMarker](providers_ocaml.md#ocamllibraryprovider).

**WARNING** Not yet fully supported - subject to change. Use with caution.

An `boot_library` is a collection of modules packaged into an OBazl
target; it is not a single binary file. It is a OBazl convenience rule
that allows a target to depend on a collection of deps under a single
label, rather than having to list each individually.

Be careful not to confuse `boot_library` with `ocaml_archive`. The
latter generates OCaml binaries (`.cma`, `.cmxa`, '.a' archive files);
the former does not generate anything, it just passes on its
dependencies under a single label, packaged in a
[OcamlLibraryMarker](providers_ocaml.md#ocamllibraryprovider). For
more information see [Collections: Libraries, Archives and
Packages](../ug/collections.md).
    """,
    attrs = dict(
        # rule_options,

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        ## GLOBAL CONFIGURABLE DEFAULTS (all ppx_* rules)
        # _debug           = attr.label(default = ws + "//debug"),
        # _cmt             = attr.label(default = ws + "//cmt"),
        # _keep_locs       = attr.label(default = ws + "//keep-locs"),
        # _noassert        = attr.label(default = ws + "//noassert"),
        # _opaque          = attr.label(default = ws + "//opaque"),
        # _short_paths     = attr.label(default = ws + "//short-paths"),
        # _strict_formats  = attr.label(default = ws + "//strict-formats"),
        # _strict_sequence = attr.label(default = ws + "//strict-sequence"),
        # _verbose         = attr.label(default = ws + "//verbose"),

        # _mode       = attr.label(
        #     default = "//bzl/toolchain",
        # ),

        # mode       = attr.string(
        #     doc     = "Overrides mode build setting.",
        #     # default = ""
        # ),

        # _toolchain = attr.label(
        #     default = "//bzl/toolchain:tc"
        # ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        #FIXME: underscore
        # ocamlc = attr.label(
        #     # cfg = ocamlc_out_transition,
        #     allow_single_file = True,
        #     default = "//bzl/toolchain:ocamlc"
        # ),

        # stdlib = attr.label(
        #     doc = "For building the compiler, if -nostdlib passed.",
        #     allow_single_file = True,
        #     cfg = manifest_out_transition,
        # ),

        manifest = attr.label_list(
            doc = "List of elements of library, which may be compiled modules, signatures, or other libraries.",

            ## will set ns config for packed modules if 'ns' not null
            # cfg = manifest_out_transition,

            providers = [
                # [OcamlArchiveProvider],
                [OcamlLibraryMarker],
                [ModuleInfo],
                [OcamlNsResolverProvider],
                # [OcamlNsMarker],
                [OcamlSignatureProvider],
            ],
        ),

        pack_ns = attr.string(
            doc = """Name(space) to use to build a packed module using -pack.
            Will be passed to submodules by a transition function, using global setting //config/pack/ns.
"""
        ),

        _rule = attr.string( default = "boot_library" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # provides = [OcamlLibraryMarker],
    executable = False,
    toolchains = ["//toolchain/type:bootstrap"]
)
