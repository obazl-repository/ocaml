load("//ocaml:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlProvider",
     "OcamlLibraryMarker",
     "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlNsResolverProvider")

load("//ocaml/_transitions:transitions.bzl",
     "nslib_in_transition")

load("//ocaml/_transitions:ns_transitions.bzl",
     "bootstrap_nslib_submodules_out_transition",
     "ocaml_nslib_submodules_out_transition")

load(":impl_library.bzl", "impl_library")

load(":options.bzl",
     "options",
     "options_ns_opts",
     "options_ns_library")

###############################
def _bootstrap_library(ctx):

    tc = ctx.toolchains["//bzl/toolchain:bootstrap"]

    ##mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    # if mode == "bytecode":
    tool = tc.ocamlrun
    tool_args = [tc.ocamlc]
    # else:
    #     tool = tc.ocamlrun.opt
    #     tool_args = []

    return impl_library(ctx, mode, tool, tool_args)

################################
rule_options = options("ocaml")
rule_options.update(options_ns_opts("ocaml"))
rule_options.update(options_ns_library("ocaml"))
# rule_options.update(options_ppx)

################
bootstrap_ns_library = rule(
    implementation = _bootstrap_library,
    doc = """Generate a 'namespace' module. [User Guide](../ug/ocaml_ns.md).  Provides: [OcamlNsMarker](providers_ocaml.md#ocamlnsmoduleprovider).

**NOTE** 'name' must be a legal OCaml module name string.  Leading underscore is illegal.

See [Namespacing](../ug/namespacing.md) for more information on namespaces.

    """,
    attrs = dict(
        rule_options,

        resolver = attr.label(
            doc = "User-provided resolver module",
            allow_single_file = True,
            providers = [OcamlModuleMarker],
            # default = "@ocaml//bootstrap/ns:resolver",
            # cfg = ocaml_nslib_submodules_out_transition
        ),

        ## we need this when we have sublibs but no direct submodules
        _ns_resolver = attr.label(
            doc = "Experimental",
            # allow_single_file = True,
            providers = [OcamlNsResolverProvider],
            default = "@ocaml//bootstrap/ns:resolver",
            cfg = bootstrap_nslib_submodules_out_transition
        ),

        _rule = attr.string(default = "ocaml_ns_library")
    ),
    cfg     = nslib_in_transition,
    provides = [OcamlNsMarker, OcamlLibraryMarker, OcamlProvider],
    executable = False,
    toolchains = ["//bzl/toolchain:bootstrap"],
)
