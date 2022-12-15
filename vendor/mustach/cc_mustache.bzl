load("@bazel_skylib//lib:paths.bzl", "paths")

# from https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_compile/my_c_compile.bzl

# also https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_archive/my_c_archive.bzl

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "PREPROCESS_ASSEMBLE_ACTION_NAME")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

ACTION = PREPROCESS_ASSEMBLE_ACTION_NAME

DISABLED_FEATURES = [
    "module_maps",
]

###########################
def _cc_mustache_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:mustache"]

    # hdr = ctx.actions.declare_file("foobar.h", sibling=ctx.file.json)
    # print("out: %s" % ctx.outputs.out.path)
    # print("HDR: %s" % hdr.path)
    # fail()

    args = ctx.actions.args()
    args.add_all(["-j", ctx.file.json.path])
    args.add_all(["-t", ctx.file.template.path])
    # args.add_all(["-o", outfile.path])
    args.add_all(["-o", ctx.outputs.out.path])

    for var in ctx.var:
        print("VAR: {k}: {v}".format(k=var, v=ctx.var[var]))

    ctx.actions.run(
        mnemonic = "CCMustache",
        executable = tc.mustache, ## ctx.file._tool,
        arguments = [args],
        inputs = depset(
            [ctx.file.template, ctx.file.json],
        ),
        outputs = [ctx.outputs.out],
    )

    cc_toolchain = find_cpp_toolchain(ctx)
    # source_file = ctx.file.src
    # ofile = source_file.basename
    # ext   = source_file.extension
    # ofile = source_file.basename[:-(len(ext)+1)]
    # output_file = ctx.actions.declare_file(ofile + ".o")

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )

    compilation_ctx = cc_common.create_compilation_context(
        # direct_headers = [ctx.outputs.out],
        direct_public_headers = [ctx.outputs.out],
        headers = depset([ctx.outputs.out]),
        ## includes: set of search paths
        includes = depset([
            #bazel will add these as e.g. -Ibazel-out/darwin-fastbuild/bin
            # srcs in runtime/caml may directly #include "foo.h"
            ctx.outputs.out.dirname,
            # srcs in runtime may #include "caml/foo.h"
            paths.dirname(ctx.outputs.out.dirname)
        ]),
        quote_includes = depset([ctx.outputs.out.dirname]),
        # system_includes=unbound,
        # framework_includes=unbound,
        # defines=unbound,
        # local_defines=unbound
    )

    ccinfo = CcInfo(
        compilation_context = compilation_ctx,
        # linking_context = cc_common.create_linking_context()
    )
    print("ccinfo: %s" % ccinfo)

    return [
        # DefaultInfo(),
        ccinfo
    ]

################################################################
cc_mustache = rule(
    implementation = _cc_mustache_impl,
    attrs = {
        "out": attr.output(mandatory = True),
        "json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "template": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),

        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"

        ),
    },
    cfg = reset_cc_config_transition,
    fragments = ["cpp"],
    toolchains = use_cpp_toolchain() + [
        "//toolchain/type:mustache",
    ]
)

