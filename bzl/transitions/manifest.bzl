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
def _manifest_in_transition_impl(settings, attr):
    # print("manifest_in_transition_impl")
    _ignore = (attr)

    return {
        "//bzl/toolchain:ocamlc" : settings["//bzl/toolchain:ocamlc"]
    }

#######################
manifest_in_transition = transition(
    implementation = _manifest_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _manifest_out_transition_impl(settings, attr):
    # print("manifest_out_transition_impl")
    # print("pack_ns: '%s'" % attr.pack_ns)

    if attr.pack_ns:
        return {"//config/pack:ns": attr.pack_ns}
    else:
        return {"//config/pack:ns": settings["//config/pack:ns"]}

#######################
manifest_out_transition = transition(
    implementation = _manifest_out_transition_impl,
    inputs = [
        "//config/pack:ns"
    ],
    outputs = [
        "//config/pack:ns"
    ]
)
