load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//toolchain:transitions.bzl", "tool_out_transition")
load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

##########################################
def _mustache_toolchain_adapter_impl(ctx):

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        mustache               = ctx.file.mustache
    )]

###################################
## the rule interface
mustache_toolchain_adapter = rule(
    _mustache_toolchain_adapter_impl,
    attrs = {
        "mustache": attr.label(
            default = "//vendor/mustach",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            # cfg = tc_compiler_out_transition
        ),

        # "_allowlist_function_transition": attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    # cfg = tc_compiler_out_transition, # toolchain_in_transition,
    doc = "Defines a toolchain for build tools (mustache)",
    provides = [platform_common.ToolchainInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html

    ## fragments: linux, apple?
    fragments = ["cpp", "platform"], ## "apple"],
    host_fragments = ["cpp", "platform"], ##, "apple"],

    ## executables need this to link cc stuff:
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"]
)
