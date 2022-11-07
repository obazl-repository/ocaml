load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlArchiveProvider",
     "OcamlExecutableMarker",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlNsMarker",
     "BootInfo",
     "OcamlSignatureProvider",
     "OcamlTestMarker")

load(":impl_executable.bzl", "impl_executable")

load(":BUILD.bzl", "exe_deps_out_transition")

load(":boot_attrs_executable.bzl", "options_executable")

# load(":options.bzl",
#      "options",
#      "options_executable",
#      "get_options")

################################################################
rule_options = options_executable("ocaml")

########################
boot_executable = rule(
    implementation = impl_executable,

    doc = "Links OCaml executable binary using the bootstrap toolchain",

    attrs = dict(
        rule_options,

        _rule = attr.string( default = "boot_executable" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    toolchains = ["//toolchain/type:bootstrap"],
)
