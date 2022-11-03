
## exports:
##   cc_build_profile - exposes tc fields as Make vars
##   cc_toolchain_profile           (rule)
##   cc_toolchain_profile_selector  (macro wrapping native.toolchain rule)

def _cc_build_profile_impl(ctx):

    tcp = ctx.toolchains["//toolchain/type:cc_tc_profile"]

    return [
        platform_common.TemplateVariableInfo({
            ## flags for cc rules
            "OC_CFLAGS"   : " ".join(tcp.CFLAGS),
            "OC_CPPFLAGS" : " ".join(tcp.CPPFLAGS),
            "OC_LDFLAGS"  : " ".join(tcp.LDFLAGS),
            "OC_DEFINES"  : " ".join(tcp.DEFINES),

            # ## ocaml compile flags
            # "OCAML_COPTS"   : " ".join(tcp.CFLAGS),
            # ## ocaml link flags
            # "OCAML_LOPTS"   : " ".join(tcp.CFLAGS),
        }),
    ]

#####################
cc_build_profile = rule(
    _cc_build_profile_impl,
    # attrs = {
    #     "fld": attr.string()
    # },
    doc = "Exposes selected cc_toolchain_profile fields.",
    provides = [platform_common.TemplateVariableInfo],
    toolchains = ["//toolchain/type:cc_tc_profile"]
)

#############################
def _cc_toolchain_profile_impl(ctx):

    return [
        platform_common.ToolchainInfo(
            name     = ctx.label.name,

            CFLAGS   = ctx.attr.CFLAGS,
            CPPFLAGS = ctx.attr.CPPFLAGS,
            LDFLAGS  = ctx.attr.LDFLAGS,
            DEFINES  = ctx.attr.DEFINES,

            # OCAML_COPTS   = ctx.attr.OCAML_COPTS,
            # OCAML_LOPTS   = ctx.attr.OCAML_LOPTS,
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
        "DEFINES": attr.string_list(
            doc     = "DEFINEs.",
        ),

        # "OCAML_COPTS": attr.string_list(
        #     doc     = "OCaml compile options.",
        # ),
        # "OCAML_LOPTS": attr.string_list(
        #     doc     = "OCaml link options.",
        # ),
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
