load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:functions.bzl", "get_workdir", "tc_lexer")

# rule: cc_binary builds ocamlyacc
# rule: yacc runs it, obtained from tc

################################################################
def _yacc_impl(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAMLYACC: %s" % ctx.label.name)

    tc = ctx.toolchains["//toolchain/type:boot"]
    # (executor, emitter, workdir) = get_workdir(ctx, tc)

    # lexout_fname = paths.replace_extension(ctx.file.src.basename, ".ml")
    # lexout = ctx.actions.declare_file(lexout_fname)

    # runner = None
    # for rf in tc.compiler[0][DefaultInfo].default_runfiles.files.to_list():
    #     if rf.path.endswith("ocamlrun"):
    #         # print("lex OCAMLRUN: %s" % rf.path)
    #         runner = rf.path

    #########################
    args = ctx.actions.args()

    inputs_depset = depset(
        direct = [
            ctx.file.src,
        ],
    )

    args.add_all(ctx.attr.opts)

    # args.add("-o", ctx.outputs.out)
    args.add(ctx.file.src)

    # The Problem: ocamlyacc does not accept -o, so we cannot write to
    # ctx.outputs.outs
    hackouts = []
    for f in ctx.outputs.outs:
        hackouts.append(ctx.actions.declare_file(f.basename,
                                                 sibling = ctx.file.src))

    for h in hackouts:
        print("HOUT: %s" % h.path)

    ctx.actions.run(
        executable = tc.yaccer,
        arguments = [args],
        inputs = inputs_depset,
        outputs = hackouts,
        tools = [tc.yaccer],
        mnemonic = "OcamlYacc",
        progress_message = "yacc: //{pkg}:{tgt}".format(
            ws  = ctx.label.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name
        )
    )

    return [DefaultInfo(files = depset(direct = hackouts))]
    # return [DefaultInfo(files = depset(direct = ctx.outputs.outs))]

#################
yacc = rule(
    implementation = _yacc_impl,
    doc = "Generates an OCaml source file from an ocamlyacc grammar.",

    attrs = dict(

        src = attr.label(
            doc = "A single .mly source file label",
            allow_single_file = [".mly"]
        ),

        outs = attr.output_list(
            mandatory = True,
        ),

        opts = attr.string_list(
            doc = "Options"
        ),
    ),
    executable = False,
    toolchains = ["//toolchain/type:boot"]
                  # ## //toolchain/type:profile,",
                  # "@bazel_tools//tools/cpp:toolchain_type"]
)
