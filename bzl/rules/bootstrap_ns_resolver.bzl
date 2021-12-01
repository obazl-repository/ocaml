load(":options.bzl", "options", "options_ns_resolver")

load("//bzl/providers:ocaml.bzl",
     "CompilationModeSettingProvider",
     "OcamlNsResolverProvider")

load("//bzl/rules:impl_ns_resolver.bzl", "impl_ns_resolver")

###############################
def _bootstrap_ns_resolver(ctx):

    tc = ctx.toolchains["//bzl/toolchain:bootstrap"]

    ##mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    # if mode == "bytecode":
    tool = tc.ocamlrun
    tool_args = [tc.ocamlc]
    # else:
    #     tool = tc.ocamlrun.opt
    #     tool_args = []

    return impl_ns_resolver(ctx, mode, tool, tool_args)

#########################
rule_options = options("ocaml")
rule_options.update(options_ns_resolver("ocaml"))

bootstrap_ns_resolver = rule(
  implementation = _bootstrap_ns_resolver,
    doc = "NS Resolver for bootstrapping the OCaml compiler",
    attrs = dict(
        rule_options,

        _warnings  = attr.label(default = "@ocaml//ns:warnings"),

        _rule = attr.string(default = "bootstrap_ns_resolver")
    ),
    provides = [OcamlNsResolverProvider],
    executable = False,
    toolchains = [
        "//bzl/toolchain:bootstrap",
    ],
)
