load("//bzl:providers.bzl",
     "ModuleInfo",
     "StdLibMarker",
     "StdlibLibMarker",
)

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

def exec_common_attrs():

    return dict(
        opts             = attr.string_list( ),

        # warnings         = attr.string_list(
        #     doc          = "List of OCaml warning options. Will override configurable default options."
        # ),

        warnings = attr.string_list_dict(
            doc = """Keys: enable, disable, or fatal. Values: list of strings, e.g. "42", "40..42", etc. """
        ),

        _compilerlibs_archived = attr.label( # boolean
            default = "//config/ocaml/compiler/libs:archived"
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

        ## stdlib is a _runtime_ dep of the linker;
        ## the linker is hardcoded to look for stdlib.cmx?a
        ## (UNLESS -nopervasives?)

        ## which means it is a runtime dep of the linker we're using
        ## to build this target, which we get from the toolchain. So
        ## it is _not_ a dependency of this target.
        # _stdlib = attr.label(
        #     doc = "Stdlib archive", ## (not stdlib.cmx?a")
        #     # default = "//stdlib", # archive, not resolver
        #     # allow_single_file = True, # won't work with boot_library
        #     # cfg = exe_deps_out_transition,
        # ),

        ## ALL executables depend on std_exit (lowercase hardcoded in
        ## linker). We do not require the user to explicitly list it,
        ## but we do add it to the command line.

        # std_exit is a runtime dep of the linker.
        # linker is hardcoded to look for std_exit.cmx?a
        _std_exit = attr.label(
            doc = "Module linked last in every executable.",
            default = "//stdlib:Std_exit",
            allow_single_file = True,
            # cfg = exe_deps_out_transition,
        ),

        ## and ditto for camlheaders
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

#######################
def executable_attrs():

    attrs = dict(
        exec_common_attrs(),
        ocamlrun = attr.label(
            doc = "ocaml",
            allow_single_file = True,
            # default = "//toolchain:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),

        prologue = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[ModuleInfo],
                         [StdLibMarker],
                         [StdlibLibMarker],
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
            providers = [[StdLibMarker],
                         [StdlibLibMarker],
                         [ModuleInfo],
                         [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),

    )

    return attrs
