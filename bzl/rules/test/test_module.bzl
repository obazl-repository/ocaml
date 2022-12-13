load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo")
load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

######################
def _test_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

####################
test_module = rule(
    implementation = _test_module,
    doc = "Compiles a module.",
    attrs = dict(
        module_attrs(),
        dump = attr.string_list(),
        stdlib_primitives = attr.bool(default = True),
        _stdlib = attr.label(
            ## only added to depgraph if stdlib_primitives == True
            default = "//stdlib:Stdlib"
        ),
        # _resolver = attr.label(
        #     doc = "The compiler always opens Stdlib, so everything depends on it.",
        #     default = "//stdlib:Stdlib"
        # ),

        _rule = attr.string( default = "test_module" ),
    ),
    # cfg = compile_mode_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
