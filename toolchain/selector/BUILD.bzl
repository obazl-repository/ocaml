#######################
def toolchain_selector(
    name,
    adapter,
    type,
    build_host_constraints=None,
    target_host_constraints=None,
    target_host_configuration=None,
    visibility = ["//visibility:public"]):

    native.toolchain(
        name                   = name,
        toolchain              = adapter,
        toolchain_type         = type,
        exec_compatible_with   = build_host_constraints,
        target_settings        = target_host_configuration,
        target_compatible_with = target_host_constraints,
        visibility             = visibility
    )

