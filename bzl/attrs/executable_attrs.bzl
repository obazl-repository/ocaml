load("//bzl:providers.bzl",
     "ModuleInfo",
     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
)

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

#######################
def executable_attrs():

    attrs = dict(

        # _stage = attr.label(
        #     default = "//config/stage"
        # ),

        prologue = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),

        main = attr.label(
            doc = "Label of module containing entry point of executable. This module will be placed last in the list of dependencies.",
            mandatory = True,
            allow_single_file = True,
            providers = [[ModuleInfo]],
            default = None,
            # cfg = exe_deps_out_transition,
        ),

        epilogue = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),

        opts             = attr.string_list( ),

        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

        _protocol = attr.label(default = "//config/build/protocol"),

        _verbose = attr.label(default = "//config/ocaml/link:verbose"),

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

        ## _runtime attr goes in each rule - boot_compiler etc. need
        ## it, but build_tool does not.

        # std_exit is required to get a runnable executable
        # linker is hardcoded to look for std_exit.cmx?a
        std_exit = attr.label(
            doc = "Module linked last in every executable.",
            default = "//stdlib:Std_exit",
            allow_single_file = True,
            # cfg = exe_deps_out_transition,
        ),

        ## stdlib is NOT required to get a runnable,
        ## but since it is so commonly used the compiler
        ## opens it by default.
        ## linker is hardcoded to look for stdlib.cmx?a
        ## UNLESS -nopervasives?
        stdlib = attr.label(
            doc = "Stdlib archive", ## (not stdlib.cmx?a")
            default = "//stdlib", # archive, not resolver
            allow_single_file = True, # won't work with boot_library
            # cfg = exe_deps_out_transition,
        ),

        _camlheaders = attr.label_list(
            allow_files = True,
            default = ["//config/camlheaders"]
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
        cc_deps = attr.label_list(
            # reset to cc mode to opt, so these deps will be built in
            # same mode as runtimes.
            ## PROBLEM: what if we're developing the code and we want
            ## dbg? transition fns need a controlling flag so they all
            ## make the same compilation_mode transition
            cfg = reset_cc_config_transition
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
        cc_linkall = attr.label_list(
            ## equivalent to cc_library's "alwayslink"
            doc     = "True: use `-whole-archive` (GCC toolchain) or `-force_load` (Clang toolchain). Deps in this attribute must also be listed in cc_deps.",
            # providers = [CcInfo],
        ),
        cc_linkopts = attr.string_list(
            doc = "List of C/C++ link options. E.g. `[\"-lstd++\"]`.",

        ),

        _compilation_mode = attr.label(
            default = "//config/compilation_mode"
        ),

        _rule = attr.string( default  = "ocaml_executable" ),

        ## for runtime reset transition:
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _cc_toolchain = attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
    )

    return attrs
