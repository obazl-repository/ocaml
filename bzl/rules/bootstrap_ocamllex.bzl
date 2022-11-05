load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",)

# load("//ocaml/_functions:utils.bzl",
#      "get_sdkpath",
# )

load(":impl_common.bzl", "tmpdir")

## make.log:
# ./boot/ocamlrun ./boot/ocamllex -q lex/lexer.mll
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.mli
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.ml

# ./boot/ocamlrun ./ocamlopt -nostdlib -I ./stdlib -I otherlibs/dynlink  -o lex/ocamllex.opt lex/cset.cmx lex/syntax.cmx lex/parser.cmx lex/lexer.cmx lex/table.cmx lex/lexgen.cmx lex/compact.cmx lex/common.cmx lex/output.cmx lex/outputbis.cmx lex/main.cmx

########## RULE:  OCAML_INTERFACE  ################
def _bootstrap_ocamllex_impl(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAML LEX TARGET: %s" % ctx.label.name)

    # mode = ctx.attr.mode

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    if tc.target_host in ["boot", "baseline", "vm"]:
        tool = tc.tool_runner
        ext = ".cmo"
    else:
        tool = tc.lexer
        ext = ".cmx"

    tool_args = [tc.lexer]

    # env = {"PATH": get_sdkpath(ctx)}

    # lexer_fname = paths.replace_extension(ctx.file.src.basename, ".ml")

    # lexer = ctx.actions.declare_file(lexer_fname)
    lexer = ctx.outputs.out

    #########################
    args = ctx.actions.args()

    args.add_all(tc.vmargs[BuildSettingInfo].value)
    args.add_all(ctx.attr.vmargs)

    args.add_all(tool_args)

    # if mode == "native":  ## OBSOLETE? use tc.target_host?
    #     args.add("-ml")

    args.add_all(ctx.attr.opts)

    args.add("-o", lexer)

    args.add(ctx.file.src)

    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs = [ctx.file.src],
        outputs = [lexer],
        tools = [tool] + tool_args,
        mnemonic = "OcamlLex",
        progress_message = "{mode} ocaml_lex: @{ws}//{pkg}:{tgt}".format(
            mode = "TEST", # mode,
            ws  = ctx.label.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name
        )
    )

    return [DefaultInfo(files = depset(direct = [lexer]))]

#################
bootstrap_ocamllex = rule(
    implementation = _bootstrap_ocamllex_impl,
    doc = """Generates an OCaml source file from an ocamllex source file.
    """,
    attrs = dict(
        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath")
        # ),
        src = attr.label(
            doc = "A single .mll source file label",
            allow_single_file = [".mll"]
        ),
        vmargs = attr.string_list(
            doc = "Args to pass to ocamlrun when it runs ocamllex.",
        ),
        out = attr.output(
            doc = """Output filename.""",
            mandatory = True
        ),
        opts = attr.string_list(
            doc = "Options"
        ),
        # mode       = attr.string(
        #     default = "bytecode",
        # ),
        _rule = attr.string( default = "ocaml_lex" )
    ),
    # provides = [],
    executable = False,
    toolchains = ["//toolchain/type:bootstrap"]
)
