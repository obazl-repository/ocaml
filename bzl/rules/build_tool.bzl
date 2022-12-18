## WARNING: this rule only used twice:
## //tools:cvt_emit.byte
## //utils:expunge (was: //toplevel:expunge)

load(":build_tool_executable_impl.bzl", "executable_impl")
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

    ext = ".byte"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, tc, exe_name, workdir)

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
