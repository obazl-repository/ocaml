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

    attrs = dict(
        rule_options,
        _rule = attr.string( default = "bootstrap_executable" ),
    ),
    ## this is not an ns archive, and it does not use ns ConfigState,
    ## but we need to reset the ConfigState anyway, so the deps are
    ## not affected if this is a dependency of an ns aggregator.

    # cfg = compile_mode_in_transition,
    executable = True,
    toolchains = ["//bzl/toolchain:bootstrap"],
)
