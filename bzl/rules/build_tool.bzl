## WARNING: this rule only used once, for //tools:cvt_emit.byte

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/rules/common:transitions.bzl", "reset_config_transition")

load("//bzl:functions.bzl", "get_workdir")

##############################
def _build_tool_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:boot"]
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)
    if target_executor == "unspecified":
        executor = config_executor
        emitter  = config_emitter
    else:
        executor = target_executor
        emitter  = target_emitter

    if executor in ["boot", "vm"]:
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, exe_name)

#######################
build_tool = rule(
    implementation = _build_tool_impl,
    doc = "Links OCaml executable binary using the bootstrap toolchain",

    # exec_groups = {
    #     "boot": exec_group(
    #         # exec_compatible_with = [
    #         #     "//platform/constraints/ocaml/executor:vm_executor?",
    #         #     "//platform/constraints/ocaml/emitter:vm_emitter"
    #         # ],
    #         toolchains = [
    #             "@bazel_tools//tools/cpp:toolchain_type",
    #             "//toolchain/type:boot"],
    #     ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm_executor?",
        #         "//platform/constraints/ocaml/emitter:vm_emitter"
        #     ],
        #     toolchains = ["//toolchain/type:baseline"],
        # ),
    # },

    attrs = dict(
        executable_attrs(),

        # stage = attr.label(default = "//config/stage"),

        _rule = attr.string( default = "build_tool" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = reset_config_transition,
    # cfg = "exec",
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
