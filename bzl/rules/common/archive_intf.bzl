load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "DepsAggregator",
     "new_deps_aggregator",

     "OcamlArchiveProvider",
     "OcamlLibraryMarker")

####################
def archive_attrs():

    return dict(

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        primitives = attr.label(
            allow_single_file = True,
        ),

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        archive_name = attr.string(
            doc = "Name of generated archive file, without extension. Overrides `name` attribute."
        ),

        ## CONFIGURABLE DEFAULTS
        # _linkall     = attr.label(default = "@ocaml//archive/linkall"),
        # # _threads     = attr.label(default = "@ocaml//archive/threads"),
        # _warnings  = attr.label(default = "@ocaml//archive:warnings"),
        #### end options ####

        # shared = attr.bool(
        #     doc = "True: build a shared lib (.cmxs)",
        #     default = False
        # ),

        # standalone = attr.bool(
        #     doc = "True: link total depgraph. False: link only direct deps.  Default False.",
        #     default = False
        # ),

        manifest = attr.label_list(
            doc = "List of component modules.",
            providers = [[OcamlLibraryMarker],
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
