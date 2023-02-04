load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:functions.bzl", "validate_outnames")

load("//bzl/actions:signature_compile_plus.bzl",
     "signature_compile_plus")

load("//bzl/actions:signature_impl.bzl", "signature_impl")
load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")

################################################################
def _test_signature_impl(ctx):

    if not ctx.label.name[0].isupper():
        print("X: %s" % ctx.label.name[0])
        fail("test_signature name must begin with upper-case letter")

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    # return signature_impl(ctx, module_name)

    if ctx.attr.rc_expected == 0:
        if (ctx.attr.stderr_actual
            or ctx.attr.stdout_actual
            or ctx.attr.stdlog_actual):
            # compile succeeds but writes warnings to stderr
            validate_outnames(ctx, ctx.file.src.basename)
            return signature_compile_plus(ctx, module_name)
            ## return module_impl(ctx, module_name)
        else:
            # compile succeeds, no side-effects
            return signature_impl(ctx, module_name)
    else:
        # compile expected to fail
        # at least one of stdout and stderr must be specified
        if not (ctx.attr.stdout_actual or ctx.attr.stderr_actual):
            fail("If expected rc is non-zero, at least one of stdout_actual or stderr_actual must be specified.")

        validate_outnames(ctx, ctx.file.struct.basename)
        return signature_compile_plus(ctx, module_name)

#######################
test_signature = rule(
    implementation = _test_signature_impl,
    doc = "Sig rule for testing",
    attrs = dict(
        signature_attrs(),

        alerts = attr.string_list(), #default = ["++all"]),
        warnings = attr.string_list(), #default = ["@A"]),
        rc_expected = attr.int(default = 0),

        stdout_actual = attr.output(),
        stderr_actual = attr.output(),

        ## not needed?
        stdlog_actual = attr.output(), # for e.g. -dlambda dumpfile

        # stdlib_primitives = attr.bool(default = False),
        # _stdlib = attr.label(
        #     ## only added to depgraph if stdlib_primitives == True
        #     allow_single_file = True,
        #     default = "//stdlib:Stdlib"
        # ),

        _rule = attr.string( default = "test_signature" ),
    ),
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
