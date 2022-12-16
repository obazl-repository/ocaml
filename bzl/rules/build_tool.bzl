## WARNING: this rule only used once, for //tools:cvt_emit.byte

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl:functions.bzl", "get_workdir")

##############################
def _build_tool_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)

    # if config_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    if config_emitter in ["boot", "vm"]:
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, exe_name)

#######################
build_tool = rule(
    implementation = _build_tool_impl,
    doc = "Links OCaml executable binary using the bootstrap toolchain",
    attrs = dict(
        executable_attrs(),
        _rule = attr.string( default = "build_tool" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # a transition here conflicts with tc out transitioning
    # cfg = reset_config_transition,
    # cfg = "exec",
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
