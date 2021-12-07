load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl", "OcamlVerboseFlagProvider")

load("//bzl:providers.bzl",
     "OcamlArchiveProvider",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlProvider",
     "OcamlSignatureProvider")

     # "PpxExecutableMarker")

# load("//ocaml/_transitions:transitions.bzl",
#      "ocaml_module_sig_out_transition",
#      "ocaml_executable_deps_out_transition",
#      "ocaml_module_deps_out_transition")

# load("//ocaml/_transitions:ns_transitions.bzl",
#      "ocaml_module_cc_deps_out_transition",
#      "ocaml_nslib_main_out_transition",
#      "ocaml_nslib_submodules_out_transition",
#      # "ocaml_nslib_sublibs_out_transition",
#      "ocaml_nslib_ns_out_transition",
#      )

## Naming conventions:
#
#  * hidden prefix:           '_'   (e.g. _rule)
#  * ns config state prefix:  '__'  (i.e. label atts)

NEGATION_OPTS = [
    "-no-g", "-no-noassert",
    "-no-linkall",
    "-no-short-paths", "-no-strict-formats", "-no-strict-sequence",
    "-no-keep-locs", "-no-opaque",
    "-no-thread", "-no-verbose"
]

################
def options(ws):

    ws = "@" + ws

    return dict(
        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),
        ## GLOBAL CONFIGURABLE DEFAULTS (all ppx_* rules)
        _debug           = attr.label(default = ws + "//debug"),
        _cmt             = attr.label(default = ws + "//cmt"),
        _keep_locs       = attr.label(default = ws + "//keep-locs"),
        _noassert        = attr.label(default = ws + "//noassert"),
        _opaque          = attr.label(default = ws + "//opaque"),
        _short_paths     = attr.label(default = ws + "//short-paths"),
        _strict_formats  = attr.label(default = ws + "//strict-formats"),
        _strict_sequence = attr.label(default = ws + "//strict-sequence"),
        _verbose         = attr.label(default = ws + "//verbose"),

        _mode       = attr.label(
            default = ws + "//mode",
        ),
        mode       = attr.string(
            doc     = "Overrides mode build setting.",
            # default = ""
        ),

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),
    )

#######################
def options_executable(ws):

    ws = "@" + ws

    attrs = dict(
        _linkall     = attr.label(default = ws + "//executable/linkall"),
        _threads     = attr.label(default = ws + "//executable/threads"),
        _warnings  = attr.label(default   = ws + "//executable:warnings"),
        # _opts = attr.label(
        #     doc = "Hidden options.",
        #     default = "@ocaml//executable:opts"
        # ),
        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath")
        # ),
        exe  = attr.string(
            doc = "By default, executable name is derived from 'name' attribute; use this to override."
        ),
        main = attr.label(
            doc = "Label of module containing entry point of executable. This module will be placed last in the list of dependencies.",
            allow_single_file = True,
            providers = [[OcamlModuleMarker]],
            default = None,
            # cfg = ocaml_executable_deps_out_transition
        ),
        data = attr.label_list(
            allow_files = True,
            doc = "Runtime dependencies: list of labels of data files needed by this executable at runtime."
        ),
        strip_data_prefixes = attr.bool(
            doc = "Symlink each data file to the basename part in the runfiles root directory. E.g. test/foo.data -> foo.data.",
            default = False
        ),
        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlImportMarker],
                         [OcamlLibraryMarker],
                         [OcamlModuleMarker],
                         [OcamlNsMarker],
                         [CcInfo]],
            # cfg = ocaml_executable_deps_out_transition
        ),
        # _deps = attr.label(
        #     doc = "Dependency to be added last.",
        #     default = "@ocaml//executable:deps"
        # ),

        ## FIXME: add cc_linkopts?
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            ## FIXME: cc libs could come from LSPs that do not support CcInfo, e.g. rules_rust
            # providers = [[CcInfo]]
        ),
        # _cc_deps = attr.label(
        #     doc = "Global C/C++ library dependencies. Apply to all instances of ocaml_executable.",
        #     ## FIXME: cc libs could come from LSPs that do not support CcInfo, e.g. rules_rust
        #     # providers = [[CcInfo]]
        #     default = "@ocaml//executable:cc_deps"
        # ),
        cc_linkall = attr.label_list(
            ## equivalent to cc_library's "alwayslink"
            doc     = "True: use `-whole-archive` (GCC toolchain) or `-force_load` (Clang toolchain). Deps in this attribute must also be listed in cc_deps.",
            # providers = [CcInfo],
        ),
        cc_linkopts = attr.string_list(
            doc = "List of C/C++ link options. E.g. `[\"-lstd++\"]`.",

        ),
        mode = attr.label(
            default = ws + "//mode"
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )
    return attrs

#######################
def options_module(ws):

    return dict(
        # _opts     = attr.label(default = ws + "//module:opts"),     # string list
        # _linkall  = attr.label(default = ws + "//module/linkall"),  # bool
        # _threads   = attr.label(default = ws + "//module/threads"),   # bool

        ################
        # ns = attr.label(
        #     doc = "Label of ocaml_ns target"
        # ),
        # _ns_submodules = attr.label(
        #     doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
        #     default = "@ocaml//ns:submodules",  # => string_list_setting
        #     # allow_files = True,
        #     # mandatory = True
        # ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        # _ns_strategy = attr.label(
        #     doc = "Experimental",
        #     default = "@ocaml//ns:strategy"
        # ),
    )

#######################
# def options_pack_library(ws):

#     providers = [[OcamlArchiveProvider],
#                  [OcamlSignatureProvider],
#                  [OcamlLibraryMarker],
#                  [OcamlModuleMarker],
#                  [OcamlNsMarker]]

#     ws = "@" + ws

#     return dict(
#         _opts     = attr.label(default = ws + "//module:opts"),     # string list
#         _linkall  = attr.label(default = ws + "//module/linkall"),  # bool
#         _threads   = attr.label(default = ws + "//module/threads"),   # bool
#         _warnings = attr.label(default = ws + "//module:warnings"), # string list

#         ################
#         deps = attr.label_list(
#             doc = "List of OCaml dependencies.",
#             providers = providers,
#             # transition undoes changes that may have been made by ns_lib
#             # cfg = ocaml_module_deps_out_transition
#         ),
#         # _allowlist_function_transition = attr.label(
#         #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
#         # ),
#         _deps = attr.label(
#             doc = "Global deps, apply to all instances of rule. Added last.",
#             default = ws + "//module:deps"
#         ),
#         # data = attr.label_list(
#         #     allow_files = True,
#         #     doc = "Runtime dependencies: list of labels of data files needed by this module at runtime."
#         # ),
#         ################
#         cc_deps = attr.label_keyed_string_dict(
#             doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
#             """,
#             # providers = [[CcInfo]]
#             # cfg = ocaml_module_cc_deps_out_transition
#         ),
#         _cc_deps = attr.label(
#             doc = "Global cc-deps, apply to all instances of rule. Added last.",
#             default = ws + "//module:deps"
#         ),

#         ################
#         # ns = attr.label(
#         #     doc = "Label of ocaml_ns target"
#         # ),
#         # _ns_resolver = attr.label(
#         #     doc = "Experimental",
#         #     providers = [OcamlNsResolverProvider],
#         #     default = "@ocaml//ns",
#         # ),
#         # _ns_submodules = attr.label(
#         #     doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
#         #     default = "@ocaml//ns:submodules",  # => string_list_setting
#         #     # allow_files = True,
#         #     # mandatory = True
#         # ),
#         # _ns_strategy = attr.label(
#         #     doc = "Experimental",
#         #     default = "@ocaml//ns:strategy"
#         # ),
#     )

#######################
def options_ns_archive(ws):

    _submod_providers   = [
        [OcamlModuleMarker],
        [OcamlNsMarker],
        [OcamlSignatureProvider]
    ]

    ws = "@" + ws

    return dict(
        _linkall     = attr.label(default = ws +  "//archive/linkall"),
        # _threads     = attr.label(default = ws + "//ns/threads"),
        _warnings    = attr.label(default = ws + "//archive:warnings"),

        shared = attr.bool(
            doc = "True: build a shared lib (.cmxs)",
            default = False
        ),

        ns = attr.string(
            doc = "Namespace name is derived from 'name' attribute by default; use this to override."
        ),

        ## if submodules list includes a module with same name as ns,
        ## it will automatically be treated as the resolver.

        # ns_resolver = attr.label(
        #     doc = "Code to use as the ns resolver module instead of generated code. The module specified must contain pseudo-recursive alias equations for all submodules.  If this attribute is specified, an ns resolver module will be generated for resolving the alias equations of the provided module.",
        #     # allow_single_file = [".ml"]
        #     providers = [OcamlModuleMarker],
        # ),

        submodules = attr.label_list(
            doc = "List of *_module submodules",
            allow_files = [".cmo", ".cmx", ".cmi"],
            providers   = _submod_providers,
            # cfg = ocaml_nslib_submodules_out_transition
        ),

        ## so we can dump ConfigState
        _ns_prefixes   = attr.label(
            doc = "Experimental",
            default = "@ocaml//ns:prefixes"
        ),
        _ns_submodules = attr.label(
            doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
            default = "@ocaml//ns:submodules",  # => string_list_setting
            # allow_files = True,
            # mandatory = True
        ),

        _ns_resolver = attr.label(
            doc = "Experimental",
            # allow_single_file = True,
            providers = [OcamlNsResolverProvider],
            default = "@ocaml//ns",
            # cfg = ocaml_nslib_submodules_out_transition
        ),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        _mode = attr.label(
            default = ws + "//mode"
        ),
        _projroot = attr.label(
            default = "@ocaml//:projroot"
        )
    )

#######################
def options_ns_library(ws):

    ws_prefix = "@ocaml" ## + ws

    return dict(
        _opts     = attr.label(default = ws_prefix + "//module:opts"),     # string list
        _linkall  = attr.label(default = ws_prefix + "//module/linkall"),  # bool
        _threads   = attr.label(default = ws_prefix + "//module/threads"),   # bool
        _warnings = attr.label(default = ws_prefix + "//module:warnings"), # string list

        ns = attr.string(
            doc = "Namespace name is derived from 'name' attribute by default; use this to override."
        ),

        ## Note: this is for the user; transition fn uses it to populate ns:submodules
        submodules = attr.label_list(
            doc = "List of namespaced submodules; will be renamed by prefixing the namespace,",
            allow_files = [".cmo", ".cmx", ".cmi"],
            providers   = [[OcamlModuleMarker], [OcamlNsMarker]],
            # cfg = ocaml_nslib_submodules_out_transition
        ),

        deps = attr.label_list(
            doc = "Non-namespaced deps of ns. Will not be renamed.",
            allow_files = [".cmo", ".cmx", ".cmi"],
            providers   = [OcamlModuleMarker],
            # cfg = ocaml_nslib_submodules_out_transition
        ),

        ## so we can dump ConfigState
        _ns_prefixes   = attr.label(
            doc = "Experimental",
            default = "@ocaml//ns:prefixes"
        ),
        _ns_submodules = attr.label(
            doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
            default = "@ocaml//ns:submodules",  # => string_list_setting
            # allow_files = True,
            # mandatory = True
        ),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _projroot = attr.label(
            default = "@ocaml//:projroot" # used by ppx too
        ),

    )

###################
def options_ns_opts(ws):

    return dict(

        # ns = attr.string(
        #     doc = "Namespace name is derived from 'name' attribute by default; use this to override."
        # ),

        _ns_prefixes   = attr.label(
            doc = "Experimental",
            default = "@ocaml//ns:prefixes"
        ),
    )

###################
def options_ns_resolver(ws):

    ws = "@ocaml" #  + ws

    return dict(

        ns = attr.string(),

        submodules = attr.string_list(
            # default = "@ocaml//ns:submodules", # => string_list_setting
            doc = "List of filenames (not files!) from which submodule names are to be derived for aliasing. The names will be formed by truncating the extension and capitalizing the initial character. Module source code generated by ocamllex and ocamlyacc can be accomodated by using the module name for the source file and generating a .ml source file of the same name, e.g. lexer.mll -> lexer.ml.",
            # allow_files = True,
            # mandatory = True
        ),

        _ns_prefixes   = attr.label(
            doc = "Experimental",
            default = ws + "//ns:prefixes"
        ),
        # _ns_strategy = attr.label(
        #     doc = "Experimental",
        #     default = "@ocaml//ns:strategy"
        # ),
        _ns_submodules = attr.label( # _list(
            default = ws + "//ns:submodules", # => string_list_setting
            doc = "List of files from which submodule names are to be derived for aliasing. The names will be formed by truncating the extension and capitalizing the initial character. Module source code generated by ocamllex and ocamlyacc can be accomodated by using the module name for the source file and generating a .ml source file of the same name, e.g. lexer.mll -> lexer.ml.",
            allow_files = True,
            # mandatory = True
        ),
        _ns_sublibs = attr.label(
            default = ws + "//ns:sublibs",  # => string_list_setting
            doc = "List of *_ns_library submodules",
            allow_files = True,
            # mandatory = True
        ),

        # _mode = attr.label(
        #     default = ws + "//mode"
        # ),
        # _warnings  = attr.label(default = ws + "//ns:warnings"),
    )

###################
# options_ppx = dict(
#         ppx  = attr.label(
#             doc = "Label of `ppx_executable` target to be used to transform source before compilation.",
#             executable = True,
#             cfg = "exec",
#             allow_single_file = True,
#             providers = [PpxExecutableMarker]
#         ),
#         ppx_args  = attr.string_list(
#             doc = "Options to pass to PPX executable passed by the `ppx` attribute.",
#         ),
#         ppx_data  = attr.label_list(
#             doc = "PPX runtime dependencies. List of labels of files needed by the PPX executable passed via the `ppx` attribute when it is executed to transform the source file. For example, a source file using [ppx_optcomp](https://github.com/janestreet/ppx_optcomp) may import a file using extension `[%%import ]`; this file should be listed in this attribute.",
#             allow_files = True,
#         ),
#         ppx_print = attr.label(
#             doc = "Format of output of PPX transform. Value must be one of '@ppx//print:binary', '@ppx//print:text'.  See [PPX Support](../ug/ppx.md#ppx_print) for more information",
#             default = "@ppx//print"
#         ),
#         # ppx_tags  = attr.string_list(
#         #     doc = "DEPRECATED. List of tags.  Used to set e.g. -inline-test-libs, --cookies. Currently only one tag allowed."
#         # )
# )

################################################################
# options_signature = dict(

#         src = attr.label(
#             doc = "A single .mli source file label",
#             allow_single_file = [".mli", ".ml"] #, ".cmi"]
#         ),

#         ns = attr.label(
#             doc = "Bottom-up namespacing",
#             allow_single_file = True,
#             mandatory = False
#         ),

#         pack = attr.string(
#             doc = "Experimental",
#         ),

#         deps = attr.label_list(
#             doc = "List of OCaml dependencies. Use this for compiling a .mli source file with deps. See [Dependencies](#deps) for details.",
#             providers = [
#                 [OcamlProvider],
#                 [OcamlArchiveProvider],
#                 [OcamlImportMarker],
#                 [OcamlLibraryMarker],
#                 [OcamlModuleMarker],
#                 [OcamlNsMarker],
#             ],
#             # cfg = ocaml_signature_deps_out_transition
#         ),

#         data = attr.label_list(
#             allow_files = True
#         ),

#         ################################################################
#         # _ns_resolver = attr.label(
#         #     doc = "Experimental",
#         #     providers = [OcamlNsResolverProvider],
#         #     # default = "@ocaml//ns:bootstrap",
#         #     default = "@ocaml//bootstrap/ns:resolver",
#         # ),

#         # _ns_submodules = attr.label( # _list(
#         #     doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
#         #     default = "@ocaml//ns:submodules", ## NB: ppx modules use ocaml_signature
#         # ),
#     )

################################################################
def get_options(rule, ctx):
    options = []

    if hasattr(ctx.attr, "_debug"):
        if ctx.attr._debug[BuildSettingInfo].value:
            if not "-no-g" in ctx.attr.opts:
                if not "-g" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-g")

    if hasattr(ctx.attr, "_cmt"):
        if ctx.attr._cmt[BuildSettingInfo].value:
            if not "-no-bin-annot" in ctx.attr.opts:
                if not "-bin-annot" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-bin-annot")

    if hasattr(ctx.attr, "_keep_locs"):
        if ctx.attr._keep_locs[BuildSettingInfo].value:
            if not "-no-keep-locs" in ctx.attr.opts:
                if not "-keep-locs" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-keep-locs")

    if hasattr(ctx.attr, "_noassert"):
        if ctx.attr._noassert[BuildSettingInfo].value:
            if not "-no-noassert" in ctx.attr.opts:
                if not "-noassert" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-noassert")

    if hasattr(ctx.attr, "_opaque"):
        if ctx.attr._opaque[BuildSettingInfo].value:
            if not "-no-opaque" in ctx.attr.opts:
                if not "-opaque" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-opaque")

    if hasattr(ctx.attr, "_short_paths"):
        if ctx.attr._short_paths[BuildSettingInfo].value:
            if not "-no-short-paths" in ctx.attr.opts:
                if not "-short-paths" in ctx.attr.opts: # avoid dup
                    options.append("-short-paths")
    if hasattr(ctx.attr, "_strict_formats"):
        if ctx.attr._strict_formats[BuildSettingInfo].value:
            if not "-no-strict-formats" in ctx.attr.opts:
                if not "-strict-formats" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-strict-formats")

    if hasattr(ctx.attr, "_strict_sequence"):
        if ctx.attr._strict_sequence[BuildSettingInfo].value:
            if not "-no-strict-sequence" in ctx.attr.opts:
                if not "-strict-sequence" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-strict-sequence")

    # if hasattr(ctx.attr, "_verbose"):
    #     if ctx.attr._verbose[OcamlVerboseFlagProvider].value:
    #         if not "-no-verbose" in ctx.attr.opts:
    #             if not "-verbose" in ctx.attr.opts: # avoid dup, use the one in opts
    #                 options.append("-verbose")

    ################################################################
    if hasattr(ctx.attr, "_thread"):
        if ctx.attr._thread[BuildSettingInfo].value:
            if not "-no-thread" in ctx.attr.opts:
                if not "-thread" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-thread")

    if hasattr(ctx.attr, "_linkall"):
        if ctx.attr._linkall[BuildSettingInfo].value:
            if not "-no-linkall" in ctx.attr.opts:
                if not "-linkall" in ctx.attr.opts: # avoid dup
                    options.append("-linkall")

    if hasattr(ctx.attr, "_warnings"):
        if ctx.attr._warnings:
            for opt in ctx.attr._warnings[BuildSettingInfo].value:
                options.extend(["-w", opt])

    if hasattr(ctx.attr, "_opts"):
        for opt in ctx.attr._opts[BuildSettingInfo].value:
            if opt not in NEGATION_OPTS:
                options.append(opt)

    ################################################################
    ## MUST COME LAST - instance opts override configurable defaults

    for opt in ctx.attr.opts:
        if opt not in NEGATION_OPTS:
            options.append(opt)

    return options

