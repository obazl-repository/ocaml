## WARNING: this rule only used once, for //tools:cvt_emit.byte

load("//bzl/actions:tool_executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:tc_transitions.bzl", "tc_boot_in_transition")

# load("//bzl:functions.bzl", "get_workdir")
load("//toolchain/adapter:BUILD.bzl",
     "tc_compiler", "tc_executable", "tc_tool_arg",
     "tc_build_executor",
     "tc_workdir")


##############################
def _build_tool_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:boot"]

    workdir = tc_workdir(tc)

    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)

    # if config_emitter in ["boot", "vm"]:
    #     ext = ".byte"
    # else:
    #     ext = ".opt"

    ext = ".byte"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, exe_name)

#######################
build_tool = rule(
    implementation = _build_tool_impl,
    doc = "Links OCaml executable binary using the bootstrap toolchain",
    attrs = dict(
        executable_attrs(),
        _rule = attr.string( default = "build_tool" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # a transition here conflicts with tc out transitioning
    # cfg = reset_config_transition,
    # cfg = "exec",
    cfg = tc_boot_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
