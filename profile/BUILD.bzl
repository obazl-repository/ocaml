load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

## exports:
##   cc_build_profile - exposes tc fields as Make vars

def _cc_build_profile_impl(ctx):

    # tc = ctx.toolchains["//toolchain/type:boot"]
    tcp = ctx.toolchains["//toolchain/type:cc_tc_profile"]

    cctc = ctx.toolchains["@bazel_tools//tools/cpp:toolchain_type"]
    # print("CCTC: %s" % cctc)
    # print("CCTC: %s" % cctc.cc.compiler)
    # print("CCTC: %s" % cctc.cc.toolchain_id)
    # for entry in dir(cctc):
    #     print("item: %s" % entry)
    # fail("x")

    return [
        platform_common.TemplateVariableInfo({
            ## toolchain config
            "COMPILER"    : cctc.cc.compiler,
            "OC_CFLAGS"   : " ".join(tcp.CFLAGS),
            "OC_CPPFLAGS" : " ".join(tcp.CPPFLAGS),
            "OC_LDFLAGS"  : " ".join(tcp.LDFLAGS),
            "VM_LINKLIBS" : " ".join(tcp.VM_LINKLIBS),
            "SYS_LINKLIBS" : " ".join(tcp.SYS_LINKLIBS),

            ## system config
            "ARCH"        : ctx.attr.ARCH,
            "SYSTEM"      : ctx.attr.SYSTEM,
            "HOST"        : ctx.attr.HOST,
            "MODEL"       : ctx.attr.MODEL,
            "TARGET"      : ctx.attr.TARGET,

            ## Installation config
            "PREFIX"      : ctx.attr.PREFIX,
            "BINDIR"      : ctx.attr.BINDIR,
            "EXEC_PREFIX" : ctx.attr.EXEC_PREFIX,
            "LIBDIR"      : ctx.attr.LIBDIR,
        }),
    ]

#####################
cc_build_profile = rule(
    _cc_build_profile_impl,
    attrs = {
        "ARCH"        : attr.string(),
        "SYSTEM"      : attr.string(),
        "HOST"        : attr.string(),
        "TARGET"      : attr.string(),
        "MODEL"       : attr.string(),
        "PREFIX"      : attr.string(),
        "BINDIR"      : attr.string(),
        "EXEC_PREFIX" : attr.string(),
        "LIBDIR"      : attr.string(),
    },
    doc = "Exposes selected cc_toolchain_profile fields.",
    provides = [platform_common.TemplateVariableInfo],
    toolchains = [
        "@bazel_tools//tools/cpp:toolchain_type",
        "//toolchain/type:cc_tc_profile",
        # "//toolchain/type:boot",
    ]
)
