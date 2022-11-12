load("//bzl:providers.bzl", "BootInfo", "ModuleInfo")
load("//bzl/rules/common:module_intf.bzl", "module_attrs")
load("//bzl/rules/common:module_impl.bzl", "module_impl")

####################
baseline_module = rule(
    implementation = module_impl,
    doc = "Compiles a module with the bootstrap compiler.",
    exec_groups = {
        "boot": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        "baseline": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:baseline"],
        ),
    },
    attrs = dict(
        module_attrs(),
        _stdlib_resolver = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",

            default = "//stdlib:Stdlib"
        ),
        _rule = attr.string( default = "baseline_module" ),
    ),
    # cfg = compile_mode_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    # toolchains = [# "//toolchain/type:boot",
    #               # "//toolchain/type:profile",
    #               "@bazel_tools//tools/cpp:toolchain_type"]
)
