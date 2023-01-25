load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "SigInfo",
     "StdLibMarker")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load(":test_transitions.bzl",
     "vv_test_in_transition")

######################
def _test_module_impl(ctx):

    if ctx.attr.module:
        module_name = ctx.attr.module
    else:
        (this, extension) = paths.split_extension(ctx.file.struct.basename)
        module_name = this[:1].capitalize() + this[1:]

    if ctx.attr.rc_expected == 0:
        if ctx.attr.stderr_expected:
            # compile succeeds but writes warnings to stderr
            return module_impl(ctx, module_name)
        else:
            return module_impl(ctx, module_name)
    else:
        # compile expected to fail
        return module_impl(ctx, module_name)

####################
test_module_ = rule(
    implementation = _test_module_impl,
    doc = "Compiles a module.",
    attrs = dict(
        module_attrs(),

        rc_expected = attr.int(default = 0),
        stdout_actual = attr.label(
            # mandatory = True,
            allow_single_file = True,
        ),
        stdout_expected = attr.label(
            # mandatory = True,
            allow_single_file = True
        ),

        stderr_actual = attr.output(
            # mandatory = True,
            # allow_single_file = True,
        ),
        stderr_expected = attr.label(
            # mandatory = True,
            allow_single_file = True
        ),

        suppress_cmi = attr.label_list(
            doc = "For testing only: do not pass on cmi files in Providers.",
            providers = [
                [ModuleInfo],
                [SigInfo],
                [StdLibMarker],
            ],
        ),
        #FIXME: rename 'dump' > 'logging'
        dump = attr.string_list(
            doc = """
            List of 'dump' options without the -d, e.g. 'lambda' for -dambda
            """
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
def test_module(name,
                visibility = ["//visibility:public"],
                **kwargs):

    if name.endswith(".cmo") or name.endswith(".cmx"):
        fail("test_module target names are automatically suffixed with .cmo and .cmx; do not include in name attribute.")


    test_module_(
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
