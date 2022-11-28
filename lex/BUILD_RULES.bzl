load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:functions.bzl", "get_workdir", "tc_lexer")

# rule: ocamllex: builds the lexer
# rule: lex runs the lexer

## make.log:
# ./boot/ocamlrun ./boot/ocamllex -q lex/lexer.mll
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.mli
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.ml

# ./boot/ocamlrun ./ocamlopt -nostdlib -I ./stdlib -I otherlibs/dynlink  -o lex/ocamllex.opt lex/cset.cmx lex/syntax.cmx lex/parser.cmx lex/lexer.cmx lex/table.cmx lex/lexgen.cmx lex/compact.cmx lex/common.cmx lex/output.cmx lex/outputbis.cmx lex/main.cmx

################################################################
## ocamllex runner: lex()
def _lex_impl(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAML LEX TARGET: %s" % ctx.label.name)

    # mode = ctx.attr.mode

    tc = ctx.toolchains["//toolchain/type:boot"]
    (stage, executor, emitter, workdir) = get_workdir(tc)

    lexout_fname = paths.replace_extension(ctx.file.src.basename, ".ml")

    # lexout = ctx.actions.declare_file(lexout_fname)

    runner = None
    for rf in tc.compiler[0][DefaultInfo].default_runfiles.files.to_list():
        if rf.path.endswith("ocamlrun"):
            # print("lex OCAMLRUN: %s" % rf.path)
            runner = rf.path

    #########################
    args = ctx.actions.args()

    tool = None
    for f in tc_lexer(tc)[DefaultInfo].default_runfiles.files.to_list():
        if f.basename == "ocamlrun":
            # print("LEX RF: %s" % f.path)
            tool = f

    args.add(tc_lexer(tc)[DefaultInfo].files_to_run.executable.path)

    inputs_depset = depset(
        direct = [
            ctx.file.src,
        ],
        transitive = [tc_lexer(tc)[DefaultInfo].default_runfiles.files]
    )

    # args.add_all(tc.copts)
    args.add_all(tc.vmargs[BuildSettingInfo].value)

    args.add_all(ctx.attr.vmargs)

    args.add_all(ctx.attr.opts)

    args.add("-q")

    args.add("-o", ctx.outputs.out)

    args.add(ctx.file.src)

    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [ctx.outputs.out],
        tools = tc_lexer(tc)[DefaultInfo].default_runfiles.files,
        mnemonic = "OcamlLex",
        progress_message = "{mode} ocaml_lex: //{pkg}:{tgt}".format(
            mode = tc.build_host + ">" + tc.target_host[BuildSettingInfo].value,
            ws  = ctx.label.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name
        )
    )

    return [DefaultInfo(files = depset(direct = [ctx.outputs.out]))]

#################
lex = rule(
    implementation = _lex_impl,
    doc = "Generates an OCaml source file from an ocamllex source file.",
    # exec_groups = {
    #     "boot": exec_group(
    #         # exec_compatible_with = [
    #         #     "//platform/constraints/ocaml/executor:vm_executor?",
    #         #     "//platform/constraints/ocaml/emitter:vm_emitter"
    #         # ],
    #         toolchains = ["//toolchain/type:boot"],
    #     ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm_executor?",
        #         "//platform/constraints/ocaml/emitter:vm_emitter"
        #     ],
        #     toolchains = ["//toolchain/type:baseline"],
        # ),
    # },

    attrs = dict(
        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//config/stage"
        ),

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
        # out = attr.output(
        #     doc = """Output filename.""",
        #     mandatory = True
        # ),
        opts = attr.string_list(
            doc = "Options"
        ),
        # mode       = attr.string(
        #     default = "bytecode",
        # ),
        _rule = attr.string( default = "ocaml_lex" )
    ),
    executable = False,
    # fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
