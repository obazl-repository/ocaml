load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo", "OcamlArchiveProvider")

load("//bzl/attrs:archive_attrs.bzl", "archive_attrs")
load("//bzl/actions:archive_impl.bzl", "archive_impl")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")
load("//bzl/actions:signature_impl.bzl", "signature_impl")

# load("//bzl/rules/common:transitions.bzl", "stdlib_in_transition")

# load(":BUILD.bzl", "STDLIB_MANIFEST")


#### macro ####
# def stdlib(stage = None,
#            build_host_constraints = None,
#            target_host_constraints = None,
#            visibility = ["//visibility:public"]
#            ):

#     boot_stdlib(
#         name       = "stdlib",
#         stage      = stage,
#         manifest   = STDLIB_MANIFEST,
#         visibility = visibility
#     )

################################################################
def _dynlink_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    name = this[:1].capitalize() + this[1:]
    module_name = "Dynlink_compilerlibs__" + name

    return signature_impl(ctx, module_name)

########################
dynlink_signature = rule(
    implementation = _dynlink_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    # exec_groups = {
    #     "boot": exec_group(
    #         toolchains = ["//toolchain/type:boot"],
    #     ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm_executor",
        #         "//platform/constraints/ocaml/emitter:vm_emitter"
        #     ],
        #     toolchains = ["//toolchain/type:baseline"],
        # ),
    # },
    attrs = dict(
        signature_attrs(),

        _opts = attr.string_list(
            # default = ["-nostdlib"]  # in tc.copts
        ),

        _resolver = attr.label(
            default = "//otherlibs/dynlink:Dynlink_compilerlibs"
        ),

        _rule = attr.string( default = "dynlink_signature" ),
    ),
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    # fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _dynlink_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    name = this[:1].capitalize() + this[1:]
    module_name = "Dynlink_compilerlibs__" + name

    return module_impl(ctx, module_name)

#######################
dynlink_module = rule(
    implementation = _dynlink_module,
    doc = "Compiles a module with the bootstrap compiler.",
    # exec_groups = {
    #     "boot": exec_group(
    #         # exec_compatible_with = [
    #         #     "//platform/constraints/ocaml/build/executor:vm_executor",
    #         #     "//platform/constraints/ocaml/build/emitter:vm_emitter"
    #         # ],
    #         toolchains = ["//toolchain/type:boot"],
    #     ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm_executor",
        #         "//platform/constraints/ocaml/emitter:vm_emitter"
        #     ],
        #     toolchains = ["//toolchain/type:baseline"],
        # ),
    # },
    attrs = dict(
        module_attrs(),

        # _opts = attr.string_list(
        #     default = ["-open", "Dynlink_compilerlibs"],
        # ),

        _resolver = attr.label(
            default = "//otherlibs/dynlink:Dynlink_compilerlibs"
        ),

        _rule = attr.string( default = "dynlink_module" ),
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
