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
def _ocamlc_fixpoint_in_transition_impl(settings, attr):
    # print("ocamlc_fixpoint_in_transition")
    # print("  stage: %s" % settings["//bzl:stage"])
    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    return {
        "//bzl:stage": 2,
        "//bzl/toolchain:ocamlc" : "//compilers/stage1:ocamlc"
    }

ocamlc_fixpoint_in_transition = transition(
    implementation = _ocamlc_fixpoint_in_transition_impl,
    inputs = [
        "//bzl:stage",
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl:stage",
        "//bzl/toolchain:ocamlc"
    ]
)

#####################################################
def _ocamlc_fixpoint_out_transition_impl(settings, attr):
    # print("ocamlc_fixpoint_out_transition")
    # print("  stage: %s" % settings["//bzl:stage"])
    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    return {
        "//bzl:stage": 2,
        "//bzl/toolchain:ocamlc" : "//compilers/stage1:ocamlc"
    }

#######################
ocamlc_fixpoint_out_transition = transition(
    implementation = _ocamlc_fixpoint_out_transition_impl,
    inputs = [
        "//bzl:stage",
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl:stage",
        "//bzl/toolchain:ocamlc"
    ]
)
