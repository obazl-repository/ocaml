load("//bzl:providers.bzl", "BootInfo", "ModuleInfo")
load("//bzl/rules/common:module_intf.bzl", "module_attrs")
load("//bzl/rules/common:module_impl.bzl", "impl_module")

####################
boot_module = rule(
    implementation = impl_module,
    doc = "Compiles a module with the bootstrap compiler.",
    attrs = dict( module_attrs() ),
    # cfg = compile_mode_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:bootstrap",
                  # "//toolchain/type:profile",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
