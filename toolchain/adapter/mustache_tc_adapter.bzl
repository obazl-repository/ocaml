load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/transitions:tc_transitions.bzl", "tc_mustache_out_transition")

def _reset_mustach_cc_config_transition_impl(settings, attr):
    # print("reset_mustach_cc_config_transition: %s" % attr.name)

    return {
        "//command_line_option:host_compilation_mode": "opt",
        "//command_line_option:compilation_mode": "opt",

        ## these are not used by cc targets, so we set them to a
        ## unique dummy value so that the transition is always to the
        ## same configuration, so that we only build once.
        "//config/build/protocol" : "null",
        "//config/target/executor": "null",
        "//config/target/emitter" : "null",

        # "//toolchain:compiler" : "//:BUILD.bazel",
        # "//toolchain:ocamlrun" : "//:BUILD.bazel",
        # "//toolchain:runtime"  : "//:BUILD.bazel",
        # "//toolchain:cvt_emit" : "//:BUILD.bazel",
    }

#######################
reset_mustach_cc_config_transition = transition(
    implementation = _reset_mustach_cc_config_transition_impl,
    inputs = [
        "//toolchain:runtime",
        "//toolchain:ocamlrun",
    ],
    outputs = [
        "//command_line_option:host_compilation_mode",
        "//command_line_option:compilation_mode",

        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",

        # "//toolchain:compiler",
        # "//toolchain:runtime",
        # "//toolchain:ocamlrun",
        # "//toolchain:cvt_emit"
    ]
)

##########################################
def _mustache_toolchain_adapter_impl(ctx):

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        mustache               = ctx.file.mustach
    )]

###################################
## the rule interface
mustache_toolchain_adapter = rule(
    _mustache_toolchain_adapter_impl,
    attrs = {
        "mustach": attr.label(
            default = "//toolchain:mustach",
            allow_single_file = True,
            executable = True,
            # cfg = "exec",
            cfg = reset_mustach_cc_config_transition,
            # cfg = tc_mustache_out_transition
        ),

        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    cfg = reset_mustach_cc_config_transition,
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
