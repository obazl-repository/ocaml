load("//bzl:providers.bzl", "StdlibSigMarker", "CompilerSigMarker")


#######################
def signature_attrs():

    return dict(

        # _stage = attr.label(
        #     doc = "bootstrap stage",
        #     default = "//config/stage"
        # ),

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),
        nocopts = attr.bool(
            doc = "to disable use toolchain's copts"
        ),

        warnings = attr.string_list(
            doc = "List of ids, with or without '-' prefix. Do not include '-w'"
        ),

        _protocol = attr.label(default = "//config/build/protocol"),

        # no point in -verbose for sigs, they never invoke external cmds
        # _verbose = attr.label(default = "//config/ocaml/compile:verbose"),

        # primitives never needed for sigs?

        # primitives = attr.label(
        #     # default = "//runtime:primitives",
        #     allow_single_file = True,
        # ),

        # use_prims = attr.bool( # overrides global _use_prims
        #     doc = "Undocumented flag, heavily used in bootstrapping",
        #     default = False
        # ),
        # _use_prims = attr.label( ## boolean
        #     doc = "Undocumented flag, heavily used in bootstrapping",
        #     default = "//runtime:use_prims"
        # ),
        # _primitives = attr.label( ## file
        #     allow_single_file = True,
        #     default = "//runtime:primitives_dat"
        # ),

        src = attr.label(
            doc = "A single .mli source file label",
            allow_single_file = [".mli", ".ml"], #, ".cmi"]
            # cfg = "host"
        ),

        ns = attr.label(
            doc = "Bottom-up namespacing",
            allow_single_file = True,
            mandatory = False
        ),

        _pack_ns = attr.label(
            doc = """Namepace name for use with -for-pack. Set by transition function.
""",
            # default = "//config/pack:ns"
        ),

        # pack = attr.string(
        #     doc = "Experimental",
        # ),

        stdlib_deps = attr.label_list(
            doc = "Used if NOT //config/ocaml/compiler/libs:archived?.",
            providers = [StdlibSigMarker]
        ),

        deps = attr.label_list(
            doc = "List of OCaml dependencies. Use this for compiling a .mli source file with deps. See [Dependencies](#deps) for details.",
            # cfg = compile_mode_out_transition,
            providers = [
                [CompilerSigMarker],
                # BootInfo,  ## bug

                # [OcamlArchiveProvider],
                # # [OcamlImportMarker],
                # [OcamlLibraryMarker],
                # [OcamlModuleMarker],
                # [OcamlSigMarker],
                # [OcamlNsMarker],
            ],
        ),

        data = attr.label_list(
            allow_files = True
        ),

        _manifest = attr.label(
            default = "//config:manifest"
        ),

        ################################################################
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     # default = "@ocaml//ns:bootstrap",
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        # _ns_submodules = attr.label( # _list(
        #     doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
        #     default = "@ocaml//ns:submodules", ## NB: ppx modules use ocaml_signature
        # ),

        ################################################################


        # opts = attr.string_list(doc = "List of OCaml options."),

        # mode       = attr.string(
        #     doc     = "Compilation mode, 'bytecode' or 'native'",
        #     default = "bytecode"
        # ),

        # _debug           = attr.label(default = "@ocaml//debug"),

        ## RULE DEFAULTS
        # _linkall     = attr.label(default = "@ocaml//signature/linkall"), # FIXME: call it alwayslink?
        # _threads     = attr.label(default = "@ocaml//signature/threads"),
        # _warnings  = attr.label(default = "@ocaml//signature:warnings"),

        #### end options ####

        # src = attr.label(
        #     doc = "A single .mli source file label",
        #     allow_single_file = [".mli", ".ml"] #, ".cmi"]
        # ),

        # ns_submodule = attr.label_keyed_string_dict(
        #     doc = "Extract cmi file from namespaced module",
        #     providers = [
        #         [OcamlNsMarker, OcamlArchiveProvider],
        #     ]
        # ),

        # as_cmi = attr.string(
        #     doc = "For use with ns_module only. Creates a symlink from the extracted cmi file."
        # ),

        # pack = attr.string(
        #     doc = "Experimental",
        # ),

        # deps = attr.label_list(
        #     doc = "List of OCaml dependencies. Use this for compiling a .mli source file with deps. See [Dependencies](#deps) for details.",
        #     providers = [
        #         [BootInfo],
        #         [OcamlArchiveProvider],
        #         [OcamlImportMarker],
        #         [OcamlLibraryMarker],
        #         [OcamlModuleMarker],
        #         [OcamlNsMarker],
        #     ],
        #     # cfg = ocaml_signature_deps_out_transition
        # ),

        # data = attr.label_list(
        #     allow_files = True
        # ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )
