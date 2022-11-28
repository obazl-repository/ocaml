load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo")
load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

######################
def _build_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

####################
build_module = rule(
    implementation = _build_module,
    doc = "Compiles a module with the bootstrap compiler.",
    # exec_groups = {
    #     "boot": exec_group(
    #         # exec_compatible_with = [
    #         #     "//platform/constraints/ocaml/executor:vm_executor?",
    #         #     "//platform/constraints/ocaml/emitter:vm_emitter"
    #         # ],
    #         toolchains = ["//toolchain/type:boot"],
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
        module_attrs(),
        # _stdlib_resolver = attr.label(
        #     doc = "The commpiler always opens Stdlib, so everything depends on it.",

        #     default = "//stdlib:Stdlib"
        # ),
        _rule = attr.string( default = "build_module" ),
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
