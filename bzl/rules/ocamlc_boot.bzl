load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlArchiveProvider",
     "OcamlExecutableMarker",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlProvider",
     "OcamlSignatureProvider",
     "OcamlTestMarker")

load(":impl_executable.bzl", "impl_executable")

# load("//bzl/transitions:boot_compiler.bzl",
#      "boot_compiler_in_transition",
#      "boot_compiler_out_transition")

load(":options.bzl",
     "options",
     "options_executable",
     "get_options")

################################
# rule_options = options("ocaml")
# rule_options.update(options_executable("ocaml"))

rule_options = options_executable("ocaml")

########################
boot_compiler = rule(
    implementation = impl_executable,

    doc = "Builds stage 1 ocamlc using stage 0 boot/ocamlc",

    attrs = dict(
        rule_options,

        primitives = attr.label(
            default = "//runtime:primitives", # file produced by genrule
            allow_single_file = True,
            # cfg = boot_compiler_out_transition,
        ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage0"
        ),

        # ocamlc = attr.label(
        #     allow_single_file = True,
        #     default = "//boot/bin:ocamlc"
        # ),

        main = attr.label(
            doc = "Label of module containing entry point of executable. This module will be placed last in the list of dependencies.",
            # cfg = boot_compiler_out_transition,
            allow_single_file = True,
            providers = [[OcamlModuleMarker]],
            default = None,
        ),

        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            # cfg = boot_compiler_out_transition,
            providers = [[OcamlArchiveProvider],
                         [OcamlImportMarker],
                         [OcamlLibraryMarker],
                         [OcamlModuleMarker],
                         [OcamlNsMarker],
                         [CcInfo]],
        ),

        # _stdexit = attr.label(
        #     cfg = boot_compiler_out_transition,
        #     default = "//stdlib:Std_exit",
        #     allow_single_file = True
        # ),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        _rule = attr.string( default = "boot_compiler" ),
    ),
    # cfg = boot_compiler_in_transition,
    executable = True,
    toolchains = ["//toolchain/type:bootstrap"],
)
