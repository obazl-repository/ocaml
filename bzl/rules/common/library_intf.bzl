load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "ModuleInfo",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlSignatureProvider")

###################
def library_attrs():

    return dict(
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

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )
