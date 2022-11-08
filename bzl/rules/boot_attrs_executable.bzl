load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl", "OcamlVerboseFlagProvider")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",

     "OcamlArchiveProvider",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlNsMarker",
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

#######################
def options_executable(ws):

    attrs = dict(

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage0"
        ),

        main = attr.label(
            doc = "Label of module containing entry point of executable. This module will be placed last in the list of dependencies.",
            mandatory = True,
            allow_single_file = True,
            providers = [[ModuleInfo]],
            default = None,
            # cfg = exe_deps_out_transition,
        ),

        prologue = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlImportMarker],
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [OcamlNsMarker],
                         [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

        use_prims = attr.bool(
            doc = "Undocumented flag, heavily used in bootstrapping",
            default = False
            # allow_single_file = True
        ),

        ## The compiler always expects to find stdlib.cm{x}a (hardocded)
        _stdlib = attr.label(
            doc = "Stdlib",
            default = "//stdlib", # archive, not resolver
            allow_single_file = True, # won't work with boot_library
            # cfg = exe_deps_out_transition,
        ),

        _std_exit = attr.label(
            doc = "Module linked last in every executable.",
            default = "//stdlib:Std_exit",
            allow_single_file = True,
            # cfg = exe_deps_out_transition,
        ),

        exe  = attr.string(
            doc = "By default, executable name is derived from 'name' attribute; use this to override."
        ),

        data = attr.label_list(
            allow_files = True,
            doc = "Runtime dependencies: list of labels of data files needed by this executable at runtime."
        ),
        strip_data_prefixes = attr.bool(
            doc = "Symlink each data file to the basename part in the runfiles root directory. E.g. test/foo.data -> foo.data.",
            default = False
        ),
        ## FIXME: add cc_linkopts?
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            ## FIXME: cc libs could come from LSPs that do not support CcInfo, e.g. rules_rust
            # providers = [[CcInfo]]
        ),

        cc_linkall = attr.label_list(
            ## equivalent to cc_library's "alwayslink"
            doc     = "True: use `-whole-archive` (GCC toolchain) or `-force_load` (Clang toolchain). Deps in this attribute must also be listed in cc_deps.",
            # providers = [CcInfo],
        ),
        cc_linkopts = attr.string_list(
            doc = "List of C/C++ link options. E.g. `[\"-lstd++\"]`.",

        ),

        # _debug           = attr.label(default = "@ocaml//debug"),

        _rule = attr.string( default  = "ocaml_executable" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    )

    return attrs
