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
def _compile_mode_in_transition_impl(settings, attr):
    # print("compile_mode_in_transition tc: %s" % attr._mode)

    ocamlc = settings["//bzl/toolchain:ocamlc"]
    # print("ocamlc: %s" % ocamlc)

    if attr.mode == "bc_bc":
        ocamlc = "//runtime:ocamlc"
    else:
        ocamlc = "//boot/bin:ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

#######################
compile_mode_in_transition = transition(
    implementation = _compile_mode_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _compile_mode_out_transition_impl(settings, attr):
    # print("compile_mode_in_transition tc: %s" % attr._mode)

    ocamlc = settings["//bzl/toolchain:ocamlc"]
    # print("ocamlc: %s" % ocamlc)

    if attr.mode == "bc_bc":
        ocamlc = "//runtime:ocamlc"
    else:
        ocamlc = "//boot/bin:ocamlc"

    ocamlc = "//boot/bin:ocamlc"
    # ocamlc = "//runtime:ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

#######################
compile_mode_out_transition = transition(
    implementation = _compile_mode_out_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _ocamlc_fixpoint_in_transition_impl(settings, attr):
    print("ocamlc_fixpoint_in_transition")
    # print("tc: %s" % attr._toolchain[BuildSettingInfo].value)
    tc = settings["//bzl/toolchain:tc"]
    # print("tc: %s" % tc)
    # print("lbl: %s" % attr.name)
    # if hasattr(attr, "struct"):
    #     print("struct: %s" % attr.struct)
    # print("mode: %s" % attr.mode)
    # print("attr: %s" % attr)

    ocamlc = settings["//bzl/toolchain:ocamlc"]
    print("//bzl/toolchain:ocamlc: %s" % ocamlc)

    if attr._mode == "bc_bc":
        ocamlc = "//runtime:ocamlc"
    else:
        ocamlc = "//boot/bin:ocamlc"

    ocamlc = "//runtime:ocamlc"
    # ocamlc = "//boot/bin:ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

#######################
ocamlc_fixpoint_in_transition = transition(
    implementation = _ocamlc_fixpoint_in_transition_impl,
    inputs = [
        "//bzl/toolchain:tc",
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _ocamlc_fixpoint_out_transition_impl(settings, attr):
    print("ocamlc_fixpoint_out_transition")
    # print("tc: %s" % attr._toolchain[BuildSettingInfo].value)
    tc = settings["//bzl/toolchain:tc"]
    # print("tc: %s" % tc)
    # print("lbl: %s" % attr.name)
    # if hasattr(attr, "struct"):
    #     print("struct: %s" % attr.struct)
    # print("mode: %s" % attr.mode)
    # print("attr: %s" % attr)

    ocamlc = settings["//bzl/toolchain:ocamlc"]
    # print("ocamlc: %s" % ocamlc)

    if attr._mode == "bc_bc":
        ocamlc = "//runtime:ocamlc"
    else:
        ocamlc = "//boot/bin:ocamlc"

    # ocamlc = "//boot/bin:ocamlc"
    ocamlc = "//runtime:ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

#######################
ocamlc_fixpoint_out_transition = transition(
    implementation = _ocamlc_fixpoint_out_transition_impl,
    inputs = [
        "//bzl/toolchain:tc",
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _ocamlc_runtime_in_transition_impl(settings, attr):
    print("ocamlc_runtime_in_transition")

    # ocamlc = settings["//bzl/toolchain:ocamlc"]
    # print("//bzl/toolchain:ocamlc: %s" % ocamlc)

    # if attr._mode == "bc_bc":
    #     ocamlc = "//runtime:ocamlc"
    # else:
    #     ocamlc = "//boot/bin:ocamlc"

    ocamlc = "//boot/bin:ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

ocamlc_runtime_in_transition = transition(
    implementation = _ocamlc_runtime_in_transition_impl,
    inputs = [
        # "//bzl/toolchain:tc",
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _ocamlc_runtime_out_transition_impl(settings, attr):
    print("ocamlc_runtime_out_transition")

    ocamlc = "//boot/bin:ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

ocamlc_runtime_out_transition = transition(
    implementation = _ocamlc_runtime_out_transition_impl,
    inputs = [

        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _ocamlrun_in_transition_impl(settings, attr):
    print("ocamlrun_in_transition_impl")
    print("n: %s" % attr.name)
    tc = settings["//bzl/toolchain:ocamlc"]
    print("TC: %s" % tc)

    print(attr)

    ocamlc = "//boot:boot.ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

#######################
ocamlrun_in_transition = transition(
    implementation = _ocamlrun_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)

################################################################
def _ocamlrun_out_transition_impl(settings, attr):
    print("ocamlrun_out_transition_impl")
    print("n: %s" % attr.name)
    tc = settings["//bzl/toolchain:ocamlc"]
    print("TC: %s" % tc)

    ocamlc = "//boot:boot.ocamlc"

    return {
        "//bzl/toolchain:ocamlc" : ocamlc
    }

#######################
ocamlrun_out_transition = transition(
    implementation = _ocamlrun_out_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlc"
    ],
    outputs = [
        "//bzl/toolchain:ocamlc"
    ]
)
