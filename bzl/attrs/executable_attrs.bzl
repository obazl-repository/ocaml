load("//bzl:providers.bzl",
     "ModuleInfo",
     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
)

load("//bzl/rules/common:transitions.bzl", "reset_config_transition")

#######################
def executable_attrs():

    attrs = dict(

        # _stage = attr.label(
        #     default = "//config/stage"
        # ),

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
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),

        opts             = attr.string_list(
            # default = ["-nopervasives"]
        ),

        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

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
            default = "//runtime:primitives.dat"
        ),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//runtime:asmrun",
            executable = False,
            cfg = reset_config_transition
            # default = "//config/runtime" # label flag set by transition
        ),

        ## The compiler always expects to find stdlib.cm{x}a (hardocded)
        ## UNLESS -nopervasives?
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

        _camlheaders = attr.label_list(
            allow_files = True,
            default = ["//config:camlheaders"]
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
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        _cc_toolchain = attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
    )

    return attrs
