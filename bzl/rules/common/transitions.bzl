################################################################
def _compile_deps_out_transition_impl(settings, attr):
    # print("compile_deps_out_transition: %s" % attr.name)
    # for m in dir(attr):
    #     print("item: %s" % m)

    if attr.name in settings["//config:manifest"]:
        manifest = settings["//config:manifest"]
    else:
        manifest = []

    return {
            "//config:manifest": manifest
    }

compile_deps_out_transition = transition(
    implementation = _compile_deps_out_transition_impl,
    inputs = [
        "//config:manifest"
    ],
    outputs = [
        "//config:manifest"
    ]
)

################################################################
def _manifest_out_transition_impl(settings, attr):
    # print("manifest_out_transition")

    # print("settings: %s" % settings)

    # for d in dir(attr):
    #     print("attr: %s" % d)

    # for m in attr.manifest:
    #     print("item: %s" % m)

    # if settings["//platforms/xtarget"] == "sys":

    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    manifest = [str(f.package) + "/" + str(f.name) for f in attr.manifest]
    manifest.append(attr.name)

    return {
            "//config:manifest": manifest
    }

manifest_out_transition = transition(
    implementation = _manifest_out_transition_impl,
    inputs = [
        "//config:manifest"
    ],
    outputs = [
        "//config:manifest"
    ]
)

################################################################
def _exe_deps_out_transition_impl(settings, attr):
    print("exe_deps_out_transition")
    # print("  xtarget: %s" % settings["//platforms/xtarget"])

    # if settings["//platforms/xtarget"] == "sys":

    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    return {}
    #     "//command_line_option:host_platform" : "//platforms/build:boot",
    #     "//command_line_option:platforms" : "//platforms/target:boot"
    # }

exe_deps_out_transition = transition(
    implementation = _exe_deps_out_transition_impl,
    inputs = [
        # "//platforms/xtarget",
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ]
)

####################################################
# def _boot_compiler_in_transition_impl(settings, attr):
#     print("boot_compiler_in_transition")
#     # print("  stage: %s" % settings["//bzl:stage"])
#     # print("//bzl/toolchain:ocamlc: %s" %
#     #       settings["//bzl/toolchain:ocamlc"])

#     return {
#         "//command_line_option:host_platform" : "//platforms/build:boot",
#         "//command_line_option:platforms" : "//platforms/target:boot"
#     }

# boot_compiler_in_transition = transition(
#     implementation = _boot_compiler_in_transition_impl,
#     inputs = [
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms"
#     ],
#     outputs = [
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms"
#     ]
# )

# #####################################################
# def _boot_compiler_out_transition_impl(settings, attr):
#     print("boot_compiler_out_transition")
#     # print("  stage: %s" % settings["//bzl:stage"])

#     # print("//bzl/toolchain:ocamlc: %s" %
#     #       settings["//bzl/toolchain:ocamlc"])

#     return {
#         "//bzl:stage": 1,
#         "//bzl/toolchain:ocamlc" : "//boot:ocamlc"
#     }

# #######################
# boot_compiler_out_transition = transition(
#     implementation = _boot_compiler_out_transition_impl,
#     inputs = [
#         "//bzl:stage",
#         "//bzl/toolchain:ocamlc"
#     ],
#     outputs = [
#         "//bzl:stage",
#         "//bzl/toolchain:ocamlc"
#     ]
# )

