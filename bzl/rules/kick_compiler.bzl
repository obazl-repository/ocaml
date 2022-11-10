load("//bzl/rules/common:executable_impl.bzl", "impl_executable")
load("//bzl/rules/common:executable_intf.bzl", "executable_attrs")

########################
def _kick_compiler(ctx):

    tc = ctx.toolchains["//toolchain/type:kick"]

    return impl_executable(ctx, tc)

#####################
kick_compiler = rule(
    implementation = _kick_compiler,

    doc = "Builds stage 1 ocamlc using stage 0 boot/ocamlc",

    attrs = dict(
        executable_attrs(),

        primitives = attr.label(
            default = "//runtime:primitives", # file produced by genrule
            allow_single_file = True,
            # cfg = kick_compiler_out_transition,
        ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "kick_compiler" ),
    ),
    # cfg = kick_compiler_in_transition,
    executable = True,
    toolchains = ["//toolchain/type:kick"],
)
