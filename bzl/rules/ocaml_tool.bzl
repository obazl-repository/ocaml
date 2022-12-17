load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")
# load("//bzl/transitions:tc_transitions.bzl", "executable_in_transition")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

load("//bzl/transitions:tc_transitions.bzl",
     "ocaml_tool_in_transition")

load("//toolchain/adapter:BUILD.bzl",
     # "tc_compiler", "tc_executable", "tc_tool_arg",
     "tc_build_executor",
     "tc_workdir")

# load("//bzl:functions.bzl", "get_workdir")

##############################
def _ocaml_tool_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc_workdir(tc)

    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)
    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    # if executor in ["boot", "vm"]:
    #     ext = ".byte"
    # else:
    #     ext = ".opt"

    if tc_build_executor == "vm":
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, exe_name)

#######################
ocaml_tool = rule(
    implementation = _ocaml_tool_impl,

    attrs = dict(
        executable_attrs(),

        vm_only = attr.bool(default = False),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain/dev:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        # ## _runtime: for sys executor only
        # _runtime = attr.label(
        #     # allow_single_file = True,
        #     default = "//runtime:asmrun",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),

        _rule = attr.string( default = "ocaml_tool" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    ## transition here (on tools) conflicts with tc out transitioning
    # cfg = executable_in_transition,
    # cfg = ocaml_tool_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
