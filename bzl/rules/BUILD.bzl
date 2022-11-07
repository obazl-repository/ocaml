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

