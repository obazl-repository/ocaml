load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

## exports:
##   cc_toolchain_profile           (rule)
##   cc_toolchain_profile_selector  (macro wrapping native.toolchain rule)

################################################################
#############################
def _cc_toolchain_profile_impl(ctx):

    return [
        platform_common.ToolchainInfo(
            name     = ctx.label.name,

            CFLAGS   = ctx.attr.CFLAGS,
            CPPFLAGS = ctx.attr.CPPFLAGS,
            LDFLAGS  = ctx.attr.LDFLAGS,
            VM_LINKLIBS  = ctx.attr.VM_LINKLIBS,
            SYS_LINKLIBS  = ctx.attr.SYS_LINKLIBS,
        ),
    ]

#####################
cc_toolchain_profile = rule(
    _cc_toolchain_profile_impl,
    attrs = {
        "CFLAGS": attr.string_list(
            doc     = "Flags for compiling C code.",
        ),
        "CPPFLAGS": attr.string_list(
            doc     = "Flags for the C preprocessor.",
        ),
        "LDFLAGS": attr.string_list(
            doc     = "Options for linking.",
        ),
        "VM_LINKLIBS": attr.string_list(
            doc     = "Libs to link with the vm runtime (libcamlrun.a).",
        ),
        "SYS_LINKLIBS": attr.string_list(
            doc     = "Libs to link with the native runtime (libasmrun.a).",
        ),
    },
    doc = "Defines compile/archive/link options for selected CC toolchain.",
    # provides = [
    #     platform_common.ToolchainInfo,
    #     platform_common.TemplateVariableInfo
    # ]
)

################################################################
def cc_toolchain_profile_selector(
    name, profile,
    toolchain_type = "//toolchain/type:cc_tc_profile",
    build_host_constraints=None,
    target_host_constraints=None,
    constraints=None,
    visibility = ["//visibility:public"]):

    native.toolchain(
        name                   = name,
        toolchain              = profile,
        toolchain_type         = toolchain_type,
        exec_compatible_with   = build_host_constraints,
        target_compatible_with = target_host_constraints,
        target_settings        = constraints,
        visibility             = visibility
    )
