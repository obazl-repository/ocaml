load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/rules/common:impl_common.bzl", "tmpdir")

## make.log:
# ./boot/ocamlrun ./boot/ocamllex -q lex/lexer.mll
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.mli
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.ml

# ./boot/ocamlrun ./ocamlopt -nostdlib -I ./stdlib -I otherlibs/dynlink  -o lex/ocamllex.opt lex/cset.cmx lex/syntax.cmx lex/parser.cmx lex/lexer.cmx lex/table.cmx lex/lexgen.cmx lex/compact.cmx lex/common.cmx lex/output.cmx lex/outputbis.cmx lex/main.cmx

########## RULE:  OCAML_INTERFACE  ################
def impl_lexer(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAML LEX TARGET: %s" % ctx.label.name)

    # mode = ctx.attr.mode

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    if tc.target_host in ["boot", "baseline", "vm"]:
        ext = ".cmo"
    else:
        ext = ".cmx"

    # env = {"PATH": get_sdkpath(ctx)}

    # lexer_fname = paths.replace_extension(ctx.file.src.basename, ".ml")

    # lexer = ctx.actions.declare_file(lexer_fname)
    lexer = ctx.outputs.out

    #########################
    args = ctx.actions.args()

    # args.add_all(tc.copts)
    args.add_all(tc.vmargs[BuildSettingInfo].value)

    args.add_all(ctx.attr.vmargs)

    args.add_all(ctx.attr.opts)

    args.add("-o", lexer)

    args.add(ctx.file.src)

    ctx.actions.run(
        # env = env,
        executable = tc.lexer[DefaultInfo].files_to_run,
        arguments = [args],
        inputs = [ctx.file.src],
        outputs = [lexer],
        tools = [tc.lexer[DefaultInfo].files_to_run],
        mnemonic = "OcamlLex",
        progress_message = "{mode} ocaml_lex: @{ws}//{pkg}:{tgt}".format(
            mode = "TEST", # mode,
            ws  = ctx.label.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name
        )
    )

    return [DefaultInfo(files = depset(direct = [lexer]))]
