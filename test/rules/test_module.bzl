load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "SigInfo",
     "StdLibMarker")

load("//bzl:functions.bzl", "validate_outnames")
load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")
load("//bzl/actions:module_compile_plus.bzl",
     "module_compile_plus")

load(":test_transitions.bzl",
     "vv_test_in_transition")

######################
def _test_module_impl(ctx):

    (stem, extension) = paths.split_extension(ctx.file.struct.basename)
    if ctx.attr.module:
        module_name = ctx.attr.module
    else:
        module_name = stem[:1].capitalize() + stem[1:]

    if ctx.attr.rc_expected == 0:
        if (ctx.attr.stderr_actual
            or ctx.attr.stdout_actual
            or ctx.attr.stdlog_actual):
            # compile succeeds but writes warnings to stderr
            validate_outnames(ctx, ctx.file.struct.basename)
            return module_compile_plus(ctx, module_name)
            ## return module_impl(ctx, module_name)
        else:
            # compile succeeds, no side-effects
            return module_impl(ctx, module_name)
    else:
        # compile expected to fail
        # at least one of stdout and stderr must be specified
        if not (ctx.attr.stdout_actual or ctx.attr.stderr_actual):
            fail("If expected rc is non-zero, at least one of stdout_actual or stderr_actual must be specified.")

        validate_outnames(ctx, ctx.file.struct.basename)
        return module_compile_plus(ctx, module_name)

####################
test_module = rule(
    implementation = _test_module_impl,
    doc = "Compiles a module.",
    attrs = dict(
        module_attrs(),

        alerts = attr.string_list(), #default = ["++all"]),
        warnings = attr.string_list(), #default = ["@A"]),
        rc_expected = attr.int(default = 0),

        stdout_actual = attr.output(),
        stderr_actual = attr.output(),
        stdlog_actual = attr.output(), # for e.g. -dlambda dumpfile
        # stdout_expected = attr.label(allow_single_file = True),
        # stderr_expected = attr.label(allow_single_file = True),
        dump = attr.string_list( #FIXME: rename 'dump' > 'logging'
            doc = """
            List of 'dump' options without the -d, e.g. 'lambda' for -dambda
            """
        ),

        suppress_cmi = attr.label_list(
            doc = "For testing only: do not pass on cmi files in Providers.",
            providers = [
                [ModuleInfo],
                [SigInfo],
                [StdLibMarker],
            ],
        ),
        _libOCaml = attr.label(
            # allow_single_file = True,
            default = "//compilerlibs:ocamlcommon"
        ),
        # open_stdlib = attr.bool(),
        # stdlib_primitives = attr.bool(default = False),
        _stdlib = attr.label(
            ## only added to depgraph if stdlib_primitives == True
            # allow_single_file = True,
            default = "//stdlib"
        ),
        # _resolver = attr.label(
        #     doc = "The compiler always opens Stdlib, so everything depends on it.",
        #     default = "//stdlib:Stdlib"
        # ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
        _rule = attr.string( default = "test_module" ),
    ),
    ## Should not be run as direct CLI build, only as a dep of
    ## toplevel test rule, which sets config. (?)

    ## cfg must match that of test executable rules, otherwise we may
    ## get the dreaded Interface mismatch (for e.g. Stdlib)
    # cfg = vv_test_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##  MACRO: adds tag attribute
def test_module_(name,
                visibility = ["//visibility:public"],
                **kwargs):

    if name.endswith(".cmo") or name.endswith(".cmx"):
        fail("test_module target names are automatically suffixed with .cmo and .cmx; do not include in name attribute.")


    test_module(
        name   = name,
        visibility = visibility,
        tags   = ["test_module"],
        **kwargs
    )

    # test_module_vm(
    #     name   = name + ".cmo",
    #     visibility = visibility,
    #     tags   = ["test_module", "cmo"],
    #     **kwargs
    # )

    # test_module_sys(
    #     name   = name + ".cmx",
    #     visibility = visibility,
    #     tags   = ["test_module", "cmx"],
    #     **kwargs
    # )
