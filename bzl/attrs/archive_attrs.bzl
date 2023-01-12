load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "DepsAggregator",
     "new_deps_aggregator",

     "OcamlArchiveProvider",
     "OcamlLibraryMarker")

####################
def archive_attrs(): ##FIXME: rename library_attrs

    return dict(

        archive = attr.bool(
            doc = "Determines whether the lib is archived or not. Default: False",
            default = False
        ),
        archive_cc = attr.bool(
            doc = """
            Detemines whether cc deps metadata is embedded in archive - 'Extra C object files', 'Extra dynamically-loaded libraries', 'Extra C options', and 'Force custom'.
            Only takes effect if archive = True.
            If a static lib is among the deps, 'Force custom' will be set to YES (same as passing -custom).
            Default: False
            """,
            default = False
        ),
        cmxa_eligible = attr.bool(
            doc = "Determines whether lib is eligible for archiving when compiled for native targets."
        ),
        _compilerlibs_archived = attr.label(
            doc = "Global flag controlling archiving of libraries",
            default = "//config/ocaml/compiler/libs:archived"
        ),

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        _protocol = attr.label(default = "//config/build/protocol"),

        _verbose = attr.label(default = "//config/ocaml/archive:verbose"),

        use_prims = attr.bool( # overrides global _use_prims
            doc = "Undocumented flag, heavily used in bootstrapping",
            default = False
        ),
        _use_prims = attr.label( ## boolean
            doc = "Undocumented flag, heavily used in bootstrapping",
            default = "//runtime:use_prims"
        ),
        _primitives = attr.label( ## file
            allow_single_file = True,
            default = "//runtime:primitives_dat"
        ),

        archive_name = attr.string(
            doc = "Name of generated archive file, without extension. Overrides `name` attribute."
        ),

        manifest = attr.label_list(
            doc = "List of component modules.",
            providers = [[OcamlLibraryMarker],
                         [OcamlArchiveProvider],
                         [ModuleInfo],
                         [CcInfo]],
            # cfg = manifest_out_transition
        ),

        data = attr.label_list(
            doc = "Data file deps",
            allow_files = True,
        ),

        ## FIXME: do archive rules need to support cc_deps?
        ## They should be attached to members of the archive.
        ## OTOH, if the ocaml wrapper on a cc_dep consists of multiple modules
        ## it makes sense to aggregate them into an archive or library
        ## and attach the cc_dep to the latter.
        ## mklib too attaches to archive
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            providers = [[CcInfo]]
        ),

        _cc_debug = attr.label(
            doc = "Controls debug print stmts in Bazel code.",
            default = "//config/build/cc:debug"
        ),

        ## FIXME: do we need this?
        cc_linkopts = attr.string_list(
            doc = "List of C/C++ link options. E.g. `[\"-lstd++\", \"lunix\"]`.",
        ),
        # cc_linkall = attr.label_list( ## FIXME: not needed
        #     doc     = "True: use `-whole-archive` (GCC toolchain) or `-force_load` (Clang toolchain). Deps in this attribute must also be listed in cc_deps.",
        #     providers = [CcInfo],
        # ),
        _cc_linkmode = attr.label( ## FIXME: not needed?
            doc     = "Override platform-dependent link mode (static or dynamic). Configurable default is platform-dependent: static on Linux, dynamic on MacOS.",
            # default is os-dependent, but settable to static or dynamic
        ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )
