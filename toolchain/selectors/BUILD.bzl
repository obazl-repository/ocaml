#######################
def toolchain_selector(
    name,
    toolchain,
    toolchain_type = "//toolchain/type:bootstrap",
    build_host_constraints=None,
    target_host_constraints=None,
    toolchain_constraints=None,
    visibility = ["//visibility:public"]):

    native.toolchain(
        name                   = name,
        toolchain              = toolchain,
        toolchain_type         = toolchain_type,
        exec_compatible_with   = build_host_constraints,
        target_settings        = toolchain_constraints,
        target_compatible_with = target_host_constraints,
        visibility             = visibility
    )

