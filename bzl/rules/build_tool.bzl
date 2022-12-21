## WARNING: this rule only used twice:
## //tools:cvt_emit.byte
## //utils:expunge (was: //toplevel:expunge)

# load(":build_tool_executable_impl.bzl", "executable_impl")

load("//bzl/actions:executable_impl.bzl", "executable_impl")

load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:boot_transitions.bzl", "tc_boot_in_transition")
load("//bzl/transitions:tool_transitions.bzl",
     "build_tool_vm_in_transition",
     "build_tool_sys_in_transition")

##############################
def _build_tool_vm_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
build_tool_vm = rule(
    implementation = _build_tool_vm_impl,
    doc = "Links vm executable build tool.",
    attrs = dict(
        executable_attrs(),
        _rule = attr.string( default = "build_tool_vm" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = build_tool_vm_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _build_tool_sys_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
build_tool_sys = rule(
    implementation = _build_tool_sys_impl,
    doc = "Links OCaml executable binary using the bootstrap toolchain",
    attrs = dict(
        executable_attrs(),
        _rule = attr.string( default = "build_tool_sys" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = build_tool_sys_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
####  MACRO
################################################################
def build_tool(name, main,
               prologue = None,
               visibility = ["//visibility:public"],
               **kwargs):

    build_tool_vm(
        name = name + ".byte",
        main = main,
        visibility = visibility,
        **kwargs
    )

    build_tool_sys(
        name = name + ".opt",
        main = main,
        visibility = visibility,
        **kwargs
    )
