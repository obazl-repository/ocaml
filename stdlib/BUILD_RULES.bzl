load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo", "OcamlArchiveProvider")

load("//bzl/attrs:archive_attrs.bzl", "archive_attrs")
load("//bzl/actions:archive_impl.bzl", "archive_impl")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")
load("//bzl/actions:signature_impl.bzl", "signature_impl")

load("//bzl/rules/common:transitions.bzl", "stdlib_in_transition")

load(":BUILD.bzl", "STDLIB_MANIFEST")


#####################
boot_stdlib = rule(  # not used
    implementation = archive_impl,
    doc = """Generates an OCaml archive file using the bootstrap toolchain.""",
    exec_groups = {
        "boot": exec_group(
            # exec_compatible_with = [
            #     "//platform/constraints/ocaml/executor:vm?",
            #     "//platform/constraints/ocaml/emitter:vm"
            # ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm?",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },

    attrs = dict(
        archive_attrs(),

        # only boot_stdlib and boot_compiler have a public 'stage' attr
        # stage = attr.label( default = "//config/stage" ),

        _rule = attr.string( default = "boot_stdlib" ),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    provides = [OcamlArchiveProvider, BootInfo],
    cfg = stdlib_in_transition,
    executable = False,
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    # toolchains = ["//toolchain/type:boot",
    #               # "//toolchain/type:profile",
    #               "@bazel_tools//tools/cpp:toolchain_type"]
)

#### macro ####
def stdlib(stage = None,
           build_host_constraints = None,
           target_host_constraints = None,
           visibility = ["//visibility:public"]
           ):

    boot_stdlib(
        name       = "stdlib",
        stage      = stage,
        manifest   = STDLIB_MANIFEST,
        visibility = visibility
    )


################################################################
def _stdlib_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    name = this[:1].capitalize() + this[1:]
    module_name = "Stdlib__" + name

    return signature_impl(ctx, module_name)

########################
stdlib_signature = rule(
    implementation = _stdlib_signature,
    doc = "Sig rule for bootstrapping ocaml compilers",
    exec_groups = {
        "boot": exec_group(
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },
    attrs = dict(
        signature_attrs(),

        _opts = attr.string_list(
            # default = ["-nostdlib"]  # in tc.copts
        ),

        _resolver = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",
            default = "//stdlib:Stdlib"
        ),

        _rule = attr.string( default = "stdlib_signature" ),
    ),
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    # toolchains = [
    #     # "//toolchain/type:boot",
    #     "@bazel_tools//tools/cpp:toolchain_type"
    # ]
)

################################################################
def _stdlib_boot_signature(ctx):

    if ctx.label.name == "Std_exit_cmi":
        module_name = "std_exit"
    else:
        (this, extension) = paths.split_extension(ctx.file.src.basename)
        module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

########################
stdlib_boot_signature = rule(
    implementation = _stdlib_boot_signature,
    doc = "Sig rule for bootstrapping stdlib",
    exec_groups = {
        "boot": exec_group(
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },
    attrs = dict(
        signature_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib", "-nopervasives"]
        ),
        # no _stdlib_resolver
        _rule = attr.string( default = "stdlib_boot_signature" ),
    ),
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    # toolchains = [
    #     # "//toolchain/type:boot",
    #     "@bazel_tools//tools/cpp:toolchain_type"
    # ]
)

################################################################
################################################################
def _stdlib_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    name = this[:1].capitalize() + this[1:]
    module_name = "Stdlib__" + name

    return module_impl(ctx, module_name)

#######################
stdlib_module = rule(
    implementation = _stdlib_module,
    doc = "Compiles a module with the bootstrap compiler.",
    exec_groups = {
        "boot": exec_group(
            # exec_compatible_with = [
            #     "//platform/constraints/ocaml/build/executor:vm",
            #     "//platform/constraints/ocaml/build/emitter:vm"
            # ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },
    attrs = dict(
        module_attrs(),

        _opts = attr.string_list(
            # default = ["-nopervasives"]
            # default = ["-nostdlib"], # in tc.copts
        ),

        _resolver = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",

            default = "//stdlib:Stdlib"
        ),
        _rule = attr.string( default = "stdlib_module" ),
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

################################################################
## non-namespace rules: no _stdlib_resolver
######################
def _stdlib_boot_module(ctx):

    if ctx.label.name == "Std_exit":
        module_name = "std_exit"
    else:
        (this, extension) = paths.split_extension(ctx.file.struct.basename)
        module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

####################
stdlib_boot_module = rule(
    implementation = _stdlib_boot_module,
    doc = "Compiles a non-namespace module in stdlib pkg.",
    exec_groups = {
        "boot": exec_group(
            # exec_compatible_with = [
            #     "//platform/constraints/ocaml/executor:vm",
            #     "//platform/constraints/ocaml/emitter:vm"
            # ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },
    attrs = dict(
        module_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib"] # in toolchain copts
            ## CamlinternalFormatBasics.ml[i] add "-nopervasives"
        ),
        # no _stdlib_resolver
        _rule = attr.string( default = "stdlib_boot_module" ),
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
