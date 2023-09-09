load("//bzl:providers.bzl",
     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
     "OcamlSignatureProvider",
     "ModuleInfo",
     "StdLibMarker",
     "StdlibLibMarker",
     "StdStructMarker",
     "StdSigMarker",
     "StdlibStructMarker")

###################
def module_attrs():

    return dict(
        module = attr.string(doc = "Module name; overrides name attr"),

        opts = attr.string_list(
            doc = "List of OCaml options. Will override configurable default options."
        ),
        nocopts = attr.bool(
            doc = "to disable use toolchain's copts"
        ),

        # warnings = attr.string_list(
        #     doc = "List of ids, with or without '-/+' prefix; default is '-'. Do not include '-w'"
        # ),

        warnings = attr.string_list_dict(
            doc = """Keys: enable, disable, or fatal. Values: list of strings, e.g. "42", "40..42", etc. """
        ),

        report_warnings = attr.label(
            default = "//config/ocaml/warnings:report"
        ),

        open = attr.label_list(
            # usually //stdlib:Stdlib
        ),

        _protocol = attr.label(default = "//config/build/protocol"),

        use_prims = attr.bool( # overrides global _use_prims
            doc = "Undocumented flag, heavily used in bootstrapping",
        ),
        _use_prims = attr.label( ## boolean
            doc = "Undocumented flag, heavily used in bootstrapping",
            default = "//runtime:use_prims"
        ),

        # _primitives = attr.label( ## file
        #     allow_single_file = True,
        #     default = "//runtime:primitives_dat"
        # ),

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

        _compilerlibs_archived = attr.label( # boolean
            default = "//config/ocaml/compiler/libs:archived"
        ),

        ################
        stdlib_deps = attr.label_list(
            doc = "Used if NOT //config/ocaml/compiler/libs:archived?.",
            providers = [[StdlibStructMarker], [StdlibLibMarker]]
        ),
        libOCaml_deps = attr.label_list(
            doc = "All deps that are also in compilerlibs:ocamlcommon",
            providers = [[StdStructMarker], [StdLibMarker]]
        ),
        sig_deps = attr.label_list(
            doc = "Sig deps",
            providers = [StdSigMarker]
        ),
        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [
                [StdStructMarker, ModuleInfo],
                # [CcInfo]
                # [ModuleInfo],
                [StdLibMarker],
                # []
            ],
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
        cc_deps = attr.label_list(
            providers = [CcInfo],
        ),

        _cc_debug = attr.label(
            doc = "Controls debug print stmts in Bazel code.",
            default = "//config/build/cc:debug"
        ),

        # cc_deps = attr.label_keyed_string_dict(
            # doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            # """,
            # providers = since this is a dictionary depset, no providers
            ## but the keys must have CcInfo providers, check at build time
            # cfg = ocaml_module_cc_deps_out_transition
        # ),

        _verbose = attr.label(default = "//config/ocaml/compile:verbose"),

        _keep_asm = attr.label(
            doc = "Pass -S to retain asm sources",
            default = "//config/ocaml/cc/asm:keep"
        ),

        _xcode_sdkroot = attr.label(
            default = "@ocaml_xcode//env:sdkroot"
        ),
        _xcode_developer_dir = attr.label(
            default = "@ocaml_xcode//env:developer_dir"
        )

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),

        ## FIXME: don't need this for bootstrapping
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )
