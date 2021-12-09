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

load("//bzl/transitions:identity.bzl", "identity_out_transition")

load(":options.bzl",
     "options",
     "options_executable",
     "get_options")

################################
# rule_options = options("ocaml")
# rule_options.update(options_executable("ocaml"))

rule_options = options_executable("ocaml")

########################
bootstrap_executable = rule(
    implementation = impl_executable,

    doc = "Generates an OCaml executable binary using the bootstrap toolchain",

    # attrs = dict(
    #     rule_options,
    #     _rule = attr.string( default = "bootstrap_executable" ),
    # ),
    attrs = dict(
        rule_options,

        ## staged bootstrapping
        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        ## staged bootstrapping
        ocamlc = attr.label(
            allow_single_file = True,
            default = "//bzl/toolchain:ocamlc"
        ),

        ## the special ocamlc_* rules use out transitions, which turn
        ## dep attrs into lists. so we add identity out transitions
        ## here. they does not change the config, we just use them to
        ## make impl processing uniform.
        main = attr.label(
            doc = "Label of module containing entry point of executable. This module will be placed last in the list of dependencies.",
            allow_single_file = True,
            providers = [[OcamlModuleMarker]],
            default = None,
            cfg = identity_out_transition,
        ),

        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlImportMarker],
                         [OcamlLibraryMarker],
                         [OcamlModuleMarker],
                         [OcamlNsMarker],
                         [CcInfo]],
            cfg = identity_out_transition,
        ),

        _stdexit = attr.label(
            default = "//stdlib:Std_exit",
            allow_single_file = True,
            cfg = identity_out_transition,
        ),

        _rule = attr.string( default = "bootstrap_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    executable = True,
    toolchains = ["//bzl/toolchain:bootstrap"],
)
