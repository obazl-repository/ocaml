load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

################################################################
def _run_ocamllex_impl(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAML LEX TARGET: %s" % ctx.label.name)

    tc = ctx.toolchains["//toolchain/type:boot"]

    workdir = tc.workdir

    lexout_fname = paths.replace_extension(ctx.file.src.basename, ".ml")

    #########################
    args = ctx.actions.args()

    toolarg = tc.lexer_arg
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    # print("TCLEX: %s" % tc.lexer)
    inputs_depset = depset(
        direct = [
            ctx.file.src,
        ] + toolarg_input
        ,
        transitive = [
            tc.lexer[DefaultInfo].default_runfiles.files
        ]
    )

    # args.add_all(tc.copts)
    args.add_all(tc.vmargs[BuildSettingInfo].value)

    args.add_all(ctx.attr.vmargs)

    args.add_all(ctx.attr.opts)

    args.add("-q")

    args.add("-o", ctx.outputs.out)

    args.add(ctx.file.src)

    ctx.actions.run(
        executable = tc.lexecutable,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [ctx.outputs.out],
        tools = [tc.lexecutable],
        mnemonic = "OcamlLex",
        progress_message = progress_msg(workdir, ctx)
    )

    return [DefaultInfo(files = depset(direct = [ctx.outputs.out]))]

#################
run_ocamllex = rule(
    implementation = _run_ocamllex_impl,
    doc = "Generates an OCaml source file from an ocamllex source file.",
    attrs = dict(
        src = attr.label(
            doc = "A single .mll source file label",
            allow_single_file = [".mll"]
        ),

        out = attr.output(
            mandatory = True,
        ),

        vmargs = attr.string_list(
            doc = "Args to pass to ocamlrun when it runs ocamllex.",
        ),
        opts = attr.string_list(
            doc = "Options"
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "run_ocamllex" )
    ),
    executable = False,
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
