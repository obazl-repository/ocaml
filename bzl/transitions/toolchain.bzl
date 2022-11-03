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
def _toolchain_in_transition_impl(settings, attr):
    # print("toolchain_in_transition_impl")

    ## trying to make sure ocamlrun is only built once

    return {
        "//bzl/toolchain:ocamlrun" : "//boot/bin:ocamlrun"
    }

#######################
toolchain_in_transition = transition(
    implementation = _toolchain_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlrun"
    ],
    outputs = [
        "//bzl/toolchain:ocamlrun"
    ]
)

################################################################
def _ocamlrun_out_transition_impl(settings, attr):
    # print("ocamlrun_out_transition_impl")

    return {
        "//bzl/toolchain:ocamlrun" : "//boot/bin:ocamlrun"
    }

#######################
ocamlrun_out_transition = transition(
    implementation = _ocamlrun_out_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlrun"
    ],
    outputs = [
        "//bzl/toolchain:ocamlrun"
    ]
)
