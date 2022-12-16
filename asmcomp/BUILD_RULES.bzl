load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:functions.bzl", "get_workdir", "tc_compiler")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

# rule: cvt_emit runs //tools:cvt_emit.byte

# incoming transition to ensure this is only built once.
# use ctx.actions.expand_template, six times

########################
def _cvt_emit(ctx):

    debug_bootstrap = False
    debug = True

    tc = ctx.toolchains["//toolchain/type:ocaml"]
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)

    executable = None
    if tc.dev:
        ocamlrun = None
        effective_compiler = tc.compiler
    else:
        ocamlrun = tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list()[0]
        effective_compiler = tc_compiler(tc)[DefaultInfo].files_to_run.executable

    if tc.dev:
        build_executor = "opt"
    elif (target_executor == "unspecified"):
        if (config_executor == "sys"):
            if config_emitter == "sys":
                # ss built from ocamlopt.byte
                build_executor = "vm"
            else:
                # sv built from ocamlopt.opt
                build_executor = "sys"
        else:
            build_executor = "vm"
    elif target_executor in ["boot", "baseline", "vm"]:
        build_executor = "vm"
    elif (target_executor == "sys" and target_emitter == "sys"):
        ## ss always built by vs (ocamlopt.byte)
        build_executor = "vm"
    elif (target_executor == "sys" and target_emitter == "vm"):
        ## sv built by ss
        build_executor = "sys"

    build_executor = get_build_executor(tc)
    print("cvt ocamlrun: %s" % ocamlrun)
    print("cvtBX: %s" % build_executor)
    print("cvtTX: %s" % config_executor)
    print("cvt ef: %s" % effective_compiler)

    if config_emitter == "vm":
        exec_tools = [ocamlrun,
                      ##effective_compiler]
                      ctx.file._tool]
        executable_cmd = ocamlrun.path + " " + ctx.file._tool.path
        # if config_executor in ["sys"]:
        #     ext = ".cmx"
        # else:
        #     ext = ".cmo"
    else:
        # exec_tools = [effective_compiler]
        # executable_cmd = effective_compiler.path
        exec_tools = [ctx.file._tool]
        executable_cmd = ctx.file._tool.path
        # ext = ".cmx"

    print("EXEC TOOLS: %s" % exec_tools)
    print("exe cmd: %s" % executable_cmd)

    # executable = None
    # if tc.dev:
    #     ocamlrun = tc.ocamlrun
    #     effective_compiler = tc.compiler
    # else:
    #     ocamlrun = tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list()[0]

    #     effective_compiler = tc_compiler(tc)[DefaultInfo].files_to_run.executable

    # build_executor = get_build_executor(tc)

    # if build_executor == "vm":
    #     executable = ocamlrun
    # else:
    #     executable = effective_compiler

    # executable = ocamlrun

    # outfile = ctx.actions.declare_file(workdir + "emit.ml")

    pfx = ctx.label.package

    # args = ctx.actions.args()
    # args.add(ctx.file._tool)
    # args.add_all([">", ctx.outputs.out.path])

    ## FIXME: don't use ocamlrun to run a sys executable!

    ctx.actions.run_shell(
        mnemonic = "CvtEmit",
        outputs = [ctx.outputs.out],
        inputs  = [ctx.file.src],
        # tools attr forces build of these deps:
        tools   = exec_tools,
        command = " ".join([
            "echo '# 1 \"{pfx}/emit.mlp\"' > {out};".format(
                pfx=pfx, out = ctx.outputs.out.path),
            # ctx.file._executor.path,
            executable_cmd,
            "<",
            ctx.file.src.path,
            ">>",
            ctx.outputs.out.path
        ])
    )

    defaultInfo = DefaultInfo(
        files=depset(direct = [ctx.outputs.out]),
    )
    return defaultInfo

#####################
cvt_emit = rule(
    implementation = _cvt_emit,
    doc = "Preprocess .mlp files",
    attrs = {
        "src"   : attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        "out"  : attr.output(
            mandatory = True,
        ),
        "_tool" : attr.label(
            allow_single_file=True,
            default = ":cvt_emit"
        ),
        # "_executor": attr.label(
        #     allow_single_file = True,
        #     default = "//runtime:ocamlrun",
        #     executable = True,
        #     cfg = "exec",
        #     # cfg = reset_config_transition,
        # ),
        # "_allowlist_function_transition": attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
