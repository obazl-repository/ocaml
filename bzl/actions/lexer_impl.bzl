load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:functions.bzl", "stage_name")

## make.log:
# ./boot/ocamlrun ./boot/ocamllex -q lex/lexer.mll
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.mli
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.ml

# ./boot/ocamlrun ./ocamlopt -nostdlib -I ./stdlib -I otherlibs/dynlink  -o lex/ocamllex.opt lex/cset.cmx lex/syntax.cmx lex/parser.cmx lex/lexer.cmx lex/table.cmx lex/lexgen.cmx lex/compact.cmx lex/common.cmx lex/output.cmx lex/outputbis.cmx lex/main.cmx

########## RULE:  OCAML_INTERFACE  ################
def lexer_impl(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAML LEX TARGET: %s" % ctx.label.name)

    # mode = ctx.attr.mode

    # tc = ctx.exec_groups[ctx.attr._stage].toolchains[
    #     "//toolchain/type:{}".format(ctx.attr._stage)
    # ]
    # tc = ctx.toolchains["//toolchain/type:boot"]


    tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]

    workdir = "_{}/".format(stage_name(tc._stage))
    # stage = ctx.attr._stage[BuildSettingInfo].value
    # print("module _stage: %s" % stage)

    # tc = None
    # if stage == "boot":
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//boot/toolchain/type:boot"]
    # elif stage == "baseline":
    #     tc = ctx.exec_groups["baseline"].toolchains[
    #         "//boot/toolchain/type:baseline"]
    # elif stage == "dev":
    #     tc = ctx.exec_groups["dev"].toolchains[
    #         "//boot/toolchain/type:boot"]
    # else:
    #     print("UNHANDLED STAGE: %s" % stage)
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//boot/toolchain/type:boot"]

    if tc.target_host in ["boot", "baseline", "vm"]:
        ext = ".cmo"
    else:
        ext = ".cmx"

    # env = {"PATH": get_sdkpath(ctx)}

    # lexer_fname = paths.replace_extension(ctx.file.src.basename, ".ml")

    # lexer = ctx.actions.declare_file(lexer_fname)
    lexout = ctx.outputs.out

    runner = None
    for rf in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
        if rf.path.endswith("ocamlrun"):
            # print("lex OCAMLRUN: %s" % rf.path)
            runner = rf.path

    #########################
    args = ctx.actions.args()

    tool = None
    for f in tc.lexer[DefaultInfo].default_runfiles.files.to_list():
        if f.basename == "ocamlrun":
            # print("LEX RF: %s" % f.path)
            tool = f

    args.add(tc.lexer[DefaultInfo].files_to_run.executable.path)

    inputs_depset = depset(
        direct = [
            ctx.file.src,
        ],
        transitive = [tc.lexer[DefaultInfo].default_runfiles.files]
    )

    # args.add_all(tc.copts)
    args.add_all(tc.vmargs[BuildSettingInfo].value)

    args.add_all(ctx.attr.vmargs)

    args.add_all(ctx.attr.opts)

    args.add("-o", lexout)

    args.add(ctx.file.src)

    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [lexout],
        tools = tc.lexer[DefaultInfo].default_runfiles.files,
        mnemonic = "OcamlLex",
        progress_message = "{mode} ocaml_lex: @{ws}//{pkg}:{tgt}".format(
            mode = "TEST", # mode,
            ws  = ctx.label.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name
        )
    )

    return [DefaultInfo(files = depset(direct = [lexout]))]
