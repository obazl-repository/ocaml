################################################################
def _tool_out_transition_impl(settings, attr):
    print("TOOL_OUT_TRANSITION: cmode: %s" %  settings["//command_line_option:compilation_mode"])
    if settings["//boot/vm:dbg"]:
        mode = "dbg"
    elif settings["//boot/vm:fastbuild"]:
        mode = "fastbuild"
    else:
        mode = settings["//command_line_option:compilation_mode"]

    return {"//command_line_option:compilation_mode": mode}

#######################
tool_out_transition = transition(
    implementation = _tool_out_transition_impl,
    inputs = [
        "//boot/vm:dbg",
        "//boot/vm:fastbuild",
        "//command_line_option:compilation_mode"
    ],
    outputs = ["//command_line_option:compilation_mode"]
)
