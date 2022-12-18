load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl", "OcamlVerboseFlagProvider")

load("//bzl:providers.bzl",
     "OcamlArchiveProvider",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     # "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlSignatureProvider",

     "BootInfo",
     "ModuleInfo"
     )

     # "PpxExecutableMarker")

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

    # if hasattr(ctx.attr, "_keep_asm"):
    #     ## only if target_executor == "sys"
    #     if ctx.attr._keep_asm[BuildSettingInfo].value:
    #         if not "-no-keep-asm" in ctx.attr.opts:
    #             if not "-keep-asm" in ctx.attr.opts: # avoid dup, use the one in opts
    #                 options.append("-S")

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

    if hasattr(ctx.attr, "_verbose"):
        if ctx.attr._verbose[BuildSettingInfo].value:
            if not "-no-verbose" in ctx.attr.opts:
                if not "-verbose" in ctx.attr.opts: # avoid dup, use the one in opts
                    options.append("-verbose")

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

    if hasattr(ctx.attr, "_global_warnings"):
        if ctx.attr._warnings:
            for opt in ctx.attr._warnings[BuildSettingInfo].value:
                options.extend(["-w", opt])

    if hasattr(ctx.attr, "_global_opts"):
        for opt in ctx.attr._global_opts[BuildSettingInfo].value:
            if opt not in NEGATION_OPTS:
                options.append(opt)

    ################################################################
    ## MUST COME LAST - instance opts override configurable defaults

    for opt in ctx.attr.opts:
        if opt not in NEGATION_OPTS:
            options.append(opt)

    if hasattr(ctx.attr, "stdlib_primitives"):
        if ctx.attr.stdlib_primitives:
            if "-nopervasives" in options:
                options.remove("-nopervasives")

    return options

