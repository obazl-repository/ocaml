load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo")
load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

######################
def _boot_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

####################
boot_module = rule(
    implementation = _boot_module,
    doc = "Compiles a module with the bootstrap compiler.",
    attrs = dict(
        module_attrs(),
        _opts = attr.string_list( ),
        _rule = attr.string( default = "boot_module" ),
    ),
    # cfg = compile_mode_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
