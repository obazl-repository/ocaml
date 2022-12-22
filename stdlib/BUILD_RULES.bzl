load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo", "OcamlArchiveProvider")

load("//bzl/attrs:archive_attrs.bzl", "archive_attrs")
load("//bzl/actions:archive_impl.bzl", "archive_impl")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")
load("//bzl/actions:signature_impl.bzl", "signature_impl")

load("//bzl/rules:ocaml_transitions.bzl", "ocaml_in_transition")

load(":BUILD.bzl", "STDLIB_MANIFEST")


################################################################
def _stdlib_signature_impl(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    name = this[:1].capitalize() + this[1:]
    module_name = "Stdlib__" + name

    return signature_impl(ctx, module_name)

########################
stdlib_signature = rule(
    implementation = _stdlib_signature_impl,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        signature_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib"]  # in tc.copts
        ),
        stdlib_primitives = attr.bool(default = False),
        _stdlib = attr.label(
            default = "//stdlib:Stdlib"
        ),
        # _resolver = attr.label(
        ns = attr.label(
            doc = "The compiler always opens Stdlib, so everything depends on it.",
            default = "//stdlib:Stdlib"
        ),
        _rule = attr.string( default = "stdlib_signature" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = ocaml_in_transition,
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _stdlib_module_impl(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    name = this[:1].capitalize() + this[1:]
    module_name = "Stdlib__" + name

    return module_impl(ctx, module_name)

#######################
stdlib_module = rule(
    implementation = _stdlib_module_impl,
    doc = "Compiles a module with the bootstrap compiler.",
    attrs = dict(
        module_attrs(),
        # stdlib_primitives = attr.bool(default = False),
        # _stdlib = attr.label(
        #     default = "//stdlib:Stdlib"
        # ),
        _opts = attr.string_list(
            # default = ["-nopervasives"]
            # default = ["-nostdlib"], # in tc.copts
        ),
        # _resolver = attr.label(
        ns = attr.label(
            doc = "The compiler always opens Stdlib, so everything depends on it.",
            default = "//stdlib:Stdlib"
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
        _rule = attr.string( default = "stdlib_module" ),
    ),
    # cfg = ocaml_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _stdlib_internal_signature_impl(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

#################################
stdlib_internal_signature = rule(
    implementation = _stdlib_internal_signature_impl,
    doc = "Sig rule for bootstrapping stdlib",
    attrs = dict(
        signature_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib", "-nopervasives"]
        ),
        # no _stdlib_resolver
        _rule = attr.string( default = "stdlib_internal_signature" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = ocaml_in_transition,
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

######################################
def _stdlib_internal_module_impl(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

##############################
stdlib_internal_module = rule(
    implementation = _stdlib_internal_module_impl,
    doc = "Compiles a non-namespace module in stdlib pkg.",
    attrs = dict(
        module_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib"] # in toolchain copts
            ## CamlinternalFormatBasics.ml[i] add "-nopervasives"
        ),
        # no _stdlib_resolver
        _rule = attr.string( default = "stdlib_internal_module" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = ocaml_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
## kernel rules: no deps
################################
def _kernel_signature_impl(ctx):

    if ctx.file.src.basename == "std_exit.mli":
        module_name = "std_exit" ## lowercase
    else:
        (this, extension) = paths.split_extension(ctx.file.src.basename)
        module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

########################
kernel_signature = rule(
    implementation = _kernel_signature_impl,
    doc = "Sig rule for bootstrapping stdlib",
    attrs = dict(
        signature_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib", "-nopervasives"]
        ),
        # no _stdlib_resolver
        _rule = attr.string( default = "kernel_signature" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = ocaml_in_transition,
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

########################
def _kernel_module_impl(ctx):

    if ctx.file.struct.basename == "std_exit.ml":
        module_name = "std_exit"
    else:
        (this, extension) = paths.split_extension(ctx.file.struct.basename)
        module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

####################
kernel_module = rule(
    implementation = _kernel_module_impl,
    doc = "Compiles a non-namespace module in stdlib pkg.",
    attrs = dict(
        module_attrs(),
        _opts = attr.string_list(
            # default = ["-nostdlib"] # in toolchain copts
            ## CamlinternalFormatBasics.ml[i] add "-nopervasives"
        ),
        # no _stdlib_resolver
        _rule = attr.string( default = "kernel_module" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = ocaml_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
