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

################################################################
def _identity_in_transition_impl(settings, attr):
    # print("identity_in_transition_impl")
    _ignore = (attr)

    return {
        "//bzl/toolchain:ocamlc" : settings["//bzl/toolchain:ocamlc"]
    }

#######################
identity_in_transition = transition(
    implementation = _identity_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _identity_out_transition_impl(settings, attr):
    # print("identity_out_transition_impl")
    _ignore = (settings, attr)

    return {
        "//bzl/toolchain:ocamlc" : settings["//bzl/toolchain:ocamlc"]
    }

#######################
identity_out_transition = transition(
    implementation = _identity_out_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)
