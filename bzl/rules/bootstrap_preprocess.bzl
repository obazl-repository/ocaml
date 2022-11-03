load(":options.bzl", "options", "options_ns_resolver")

load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlNsResolverProvider")

load("//bzl/rules:impl_ns_resolver.bzl", "impl_ns_resolver")

###############################
def _bootstrap_preprocess_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    ##mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    # if mode == "bytecode":
    tool = tc.tool_runner
    tool_args = [tc.compiler]
    # else:
    #     tool = tc.tool_runner.opt
    #     tool_args = []

    return impl_ns_resolver(ctx, mode, tool, tool_args)

#########################
bootstrap_preprocess = rule(
  implementation = _bootstrap_preprocess_impl,
    doc = "Preprocess",
    attrs = dict(
        srcs = attr.label_list(),
        out  = attr.output(),
        outs = attr.output_list(),
        cmd  = attr.string()
    ),
    executable = True,
    toolchains = [
        # "//toolchain/type:bootstrap",
    ],
)
