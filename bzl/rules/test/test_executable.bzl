load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load("//bzl:functions.bzl", "get_workdir")

##############################
def _test_executable_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)
    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    if config_executor in ["boot", "vm"]:
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return executable_impl(ctx, exe_name)

#######################
test_executable = rule(
    implementation = _test_executable_impl,
    doc = "Links OCaml executable binary using the bootstrap toolchain",
    attrs = dict(
        executable_attrs(),
        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain/dev:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),
        _rule = attr.string( default = "test_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    cfg = dev_tc_compiler_out_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
