load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlLibraryMarker",
     "OcamlModuleMarker",
     "OcamlNsResolverProvider",
     "OcamlSignatureProvider")

# load(":options.bzl", "options", "options_library")

load(":impl_library.bzl", "impl_library")

###############################
def _bootstrap_library(ctx):

    tc = ctx.toolchains["//bzl/toolchain:bootstrap"]

    ##mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    # if mode == "bytecode":
    tool = tc.ocamlrun
    # tool_args = [tc.ocamlc]
    # else:
    #     tool = tc.ocamlrun.opt
    #     tool_args = []

    return impl_library(ctx, mode, tool) #, tool_args)

###############################
# rule_options = options("ocaml")
# rule_options.update(options_library("ocaml"))

#####################
bootstrap_library = rule(
    implementation = _bootstrap_library,
    doc = """Aggregates a collection of OCaml modules. [User Guide](../ug/bootstrap_library.md). Provides: [OcamlLibraryMarker](providers_ocaml.md#ocamllibraryprovider).

**WARNING** Not yet fully supported - subject to change. Use with caution.

An `bootstrap_library` is a collection of modules packaged into an OBazl
target; it is not a single binary file. It is a OBazl convenience rule
that allows a target to depend on a collection of deps under a single
label, rather than having to list each individually.

Be careful not to confuse `bootstrap_library` with `ocaml_archive`. The
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
        #     default = ws + "//mode",
        # ),
        mode       = attr.string(
            doc     = "Overrides mode build setting.",
            # default = ""
        ),

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        manifest = attr.label_list(
            doc = "List of elements of library, which may be compiled modules, signatures, or other libraries.",
            providers = [
                # [OcamlArchiveProvider],
                [OcamlLibraryMarker],
                [OcamlModuleMarker],
                [OcamlNsResolverProvider],
                # [OcamlNsMarker],
                [OcamlSignatureProvider],
            ],
        ),

        _rule = attr.string( default = "bootstrap_library" ),
    ),
    provides = [OcamlLibraryMarker],
    executable = False,
    toolchains = ["//bzl/toolchain:bootstrap"]
)
