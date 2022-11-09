load("//bzl:providers.bzl",
     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
     "OcamlSignatureProvider",
     "ModuleInfo")

###################
def module_attrs():

    return dict(

        primitives = attr.label(
            allow_single_file = True,
        ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        opts = attr.string_list(
            doc = "List of OCaml options. Will override configurable default options."
        ),

        warnings = attr.string_list(
        ),

        nocopts = attr.bool(
            doc = "to disable use toolchain's copts"
        ),

        ns = attr.label(
            doc = "Bottom-up namespacing",
            allow_single_file = True,
            mandatory = False
        ),

        struct = attr.label(
            doc = "A single module (struct) source file label.",
            mandatory = False, # pack libs may not need a src file
            allow_single_file = True # no constraints on extension
        ),

        _pack_ns = attr.label(
            doc = """Namepace name for use with -for-pack. Set by transition function.
""",
            # default = "//config/pack:ns"
        ),

        sig = attr.label(
            doc = "Single label of a target producing OcamlSignatureProvider (i.e. rule 'ocaml_signature'). Optional.",
            # cfg = compile_mode_out_transition,
            allow_single_file = True, # [".cmi"],
            ## only allow compiled sigs
            # providers = [[OcamlSignatureProvider]],
        ),

        ################
        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [CcInfo]],
            # transition undoes changes that may have been made by ns_lib
            # cfg = compile_deps_out_transition,
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        deps_runtime = attr.label_list(
            doc = "Deps needed at runtime, but not build time. E.g. .cmxs plugins.",
            allow_files = True,
        ),

        data = attr.label_list(
            allow_files = True,
            doc = "Runtime dependencies: list of labels of data files needed by this module at runtime."
        ),

        _manifest = attr.label(
            default = "//config:manifest"
        ),

        ################
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            # providers = since this is a dictionary depset, no providers
            ## but the keys must have CcInfo providers, check at build time
            # cfg = ocaml_module_cc_deps_out_transition
        ),

        _verbose = attr.label(default = "//config:verbose"),

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),

        ## FIXME: don't need this for bootstrapping
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        _rule = attr.string( default = "boot_module" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )