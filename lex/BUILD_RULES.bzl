load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

# load("//bzl:functions.bzl", "tc_lexer")

# load("//toolchain/adapter:BUILD.bzl",
#      "tc_lexer",
#      "tc_lexer_arg")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

# rule: boot_compiler(name=ocamllex): builds the lexer
# rule: lex runs the lexer, obtained from toolchain

## make.log:
# ./boot/ocamlrun ./boot/ocamllex -q lex/lexer.mll
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.mli
# ./boot/ocamlrun ./boot/ocamlc -nostdlib -I ./boot -use-prims runtime/primitives -g -strict-sequence -principal -absname -w +a-4-9-40-41-42-44-45-48 -warn-error +a -bin-annot -strict-formats -I lex -I utils -I parsing -I typing -I bytecomp -I file_formats -I lambda -I middle_end -I middle_end/closure -I middle_end/flambda -I middle_end/flambda/base_types -I asmcomp -I driver -I toplevel -c lex/lexer.ml

# ./boot/ocamlrun ./ocamlopt -nostdlib -I ./stdlib -I otherlibs/dynlink  -o lex/ocamllex.opt lex/cset.cmx lex/syntax.cmx lex/parser.cmx lex/lexer.cmx lex/table.cmx lex/lexgen.cmx lex/compact.cmx lex/common.cmx lex/output.cmx lex/outputbis.cmx lex/main.cmx

################################################################
## ocamllex runner: lex()
def _run_ocamllex_impl(ctx):

    debug = False
    if (ctx.label.name == "_Impl"):
        debug = True

    if debug:
        print("OCAML LEX TARGET: %s" % ctx.label.name)

    # mode = ctx.attr.mode

    tc = ctx.toolchains["//toolchain/type:boot"]

    workdir = tc.workdir

    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)

    # if debug:
    #     print("target_emitter: %s" % target_emitter)
    #     print("target_executor: %s" % target_executor)
    #     print("config_emitter: %s" % config_emitter)
    #     print("config_executor: %s" % config_executor)
    #     print("tc.dev: %s" % tc.dev)

    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    lexout_fname = paths.replace_extension(ctx.file.src.basename, ".ml")

    # lexout = ctx.actions.declare_file(lexout_fname)

    # runner = None
    # for rf in tc.compiler[0][DefaultInfo].default_runfiles.files.to_list():
    #     if rf.path.endswith("ocamlrun"):
    #         # print("lex OCAMLRUN: %s" % rf.path)
    #         runner = rf.path

    #########################
    args = ctx.actions.args()

    toolarg = tc.lexer_arg
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    # tool = None
    # for f in tc.lexer[DefaultInfo].default_runfiles.files.to_list():
    #     if f.basename == "ocamlrun":
    #         # print("LEX RF: %s" % f.path)
    #         tool = f

    # args.add(tc.lexer[DefaultInfo].files_to_run.executable.path)

    # if debug:
    #     print("target_emitter: %s" % target_emitter)
    #     print("target_executor: %s" % target_executor)
    #     print("config_emitter: %s" % config_emitter)
    #     print("config_executor: %s" % config_executor)
    #     print("tc.dev: %s" % tc.dev)

    # runfiles = tc.compiler[DefaultInfo].default_runfiles.files.to_list()
    # print("RUNFILES: %s" % runfiles)

    # executable = None
    # if tc.dev:
    #     ocamlrun = None
    #     effective_compiler = tc.compiler
    # else:
    #     ocamlrun = tc.compiler[DefaultInfo].default_runfiles.files.to_list()[0]

    #     effective_compiler = tc.lexer[DefaultInfo].files_to_run.executable

    # build_executor = get_build_executor(tc)

    # if tc.dev:
    #     build_executor = "opt"
    # elif (target_executor == "unspecified"):
    #     if (config_executor == "sys"):
    #         if config_emitter == "sys":
    #             # ss built from ocamlopt.byte
    #             build_executor = "vm"
    #         else:
    #             # sv built from ocamlopt.opt
    #             build_executor = "sys"
    #     else:
    #         build_executor = "vm"
    # elif target_executor in ["boot", "vm"]:
    #     build_executor = "vm"
    # elif (target_executor == "sys" and target_emitter == "sys"):
    #     ## ss always built by vs (ocamlopt.byte)
    #     build_executor = "vm"
    # elif (target_executor == "sys" and target_emitter == "vm"):
    #     ## sv built by ss
    #     build_executor = "sys"

    # if build_executor == "vm":
    #     executable = ocamlrun
    #     args.add(effective_compiler.path)
    # else:
    #     executable = effective_compiler

    print("TCLEX: %s" % tc.lexer)
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
        # env = env,
        executable = tc.lexecutable,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [ctx.outputs.out],
        tools = [tc.lexecutable],
        ## tc.lexer[DefaultInfo].default_runfiles.files,
        mnemonic = "OcamlLex",
        progress_message = progress_msg(workdir, ctx)
        # progress_message = "{mode} ocaml_lex: //{pkg}:{tgt}".format(
        #     mode = tc.build_host + ">" + tc.target_host[BuildSettingInfo].value,
        #     ws  = ctx.label.workspace_name,
        #     pkg = ctx.label.package,
        #     tgt=ctx.label.name
        # )
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
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "run_ocamllex" )
    ),
    executable = False,

    # fixme: reset transition - we only ever need one version of
    # ocamllex when compiling compilers. We can build both versions
    # (ocamllex.byte, ocamllex.opt) but we only need to *use* one.
    # Which can be boot/ocamllex?


    # cfg = reset_config_transition,
    # fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
