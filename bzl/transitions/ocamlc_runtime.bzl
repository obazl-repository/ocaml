load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/rules:impl_common.bzl",
     "dsorder", "module_sep", "resolver_suffix",
     "opam_lib_prefix",
     "tmpdir"
     )


load("//bzl:providers.bzl",
     "OcamlArchiveProvider",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlProvider",
     "OcamlSignatureProvider")

####################################################
def _ocamlc_runtime_in_transition_impl(settings, attr):
    print("ocamlc_runtime_in_transition")

    return {
        "//bzl/toolchain:ocamlc" : "//boot:ocamlc"
    }

ocamlc_runtime_in_transition = transition(
    implementation = _ocamlc_runtime_in_transition_impl,
    inputs = [
        # "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

#####################################################
def _ocamlc_runtime_out_transition_impl(settings, attr):
    print("ocamlc_runtime_out_transition")

    return {
        "//bzl/toolchain:ocamlc" : "//boot:ocamlc"
    }

#######################
ocamlc_runtime_out_transition = transition(
    implementation = _ocamlc_runtime_out_transition_impl,
    inputs = [
        # "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)
