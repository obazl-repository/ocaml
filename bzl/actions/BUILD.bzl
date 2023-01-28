load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

################
def add_dump_args(ctx, ext, args):
    if hasattr(ctx.attr, "_lambda_expect_test"):
        for arg in ctx.attr._lambda_expect_test:
            args.add(arg)

    elif hasattr(ctx.attr, "dump"): # test rules w/explicit dump attr
        if len(ctx.attr.dump) > 0:
            args.add("-dump-into-file")
        for d in ctx.attr.dump:
            if d == "source":
                args.add("-dsource")
            if d == "parsetree":
                args.add("-dparsetree")
            if d == "typedtree":
                args.add("-dtypedtree")
            if d == "shape":
                args.add("-dshape")
            if d == "rawlambda":
                args.add("-drawlambda")
            if d == "lambda":
                args.add("-dlambda")
            if d == "rawflambda":
                args.add("-drawflambda")
            if d == "flambda":
                args.add("-dflambda")
            if d == "flambda-let":
                args.add("-dflambda-let")
            if d == "flambda-verbose":
                args.add("-dflambda-verbose")

            if ext == ".cmo":
                if d == "instr":
                    args.add("-dinstr")

            if ext == ".cmx":
                if d == "clambda":
                    args.add("-dclambda")
                if d == "rawclambda":
                    args.add("-drawclambda")
                if d == "cmm":
                    args.add("-dcmm")
                if d == "instruction-selection":
                    args.add("-dsel")

#######################
def runtime_preamble(debug=False):
    args = []

    if debug:
        args.append("set -x;")
        args.append("echo PWD: $(PWD);")

    args.extend([
        # "ls -la;",
        # "echo RUNFILES_DIR: $RUNFILES_DIR;",
        "set -uo pipefail; set +e;",
        "f=bazel_tools/tools/bash/runfiles/runfiles.bash ",
        "source \"${RUNFILES_DIR:-/dev/null}/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"${RUNFILES_MANIFEST_FILE:-/dev/null}\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$0.runfiles/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.exe.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    { echo \"ERROR: cannot find $f\"; exit 1; };", ##  f=; set -e; ",
    ])
    # --- end runfiles.bash initialization v2 ---

    if debug:
        args.append("if [ -x ${RUNFILES_DIR+x} ]")
        args.append("then")
        args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
        args.append("    cat ${RUNFILES_MANIFEST_FILE}")
        args.append("else")
        args.append("    echo \"RUNFILES_DIR: ${RUNFILES_DIR}\"")
        args.append("fi")

    args.append("")

    return "\n".join(args)

#######################
def rule_mnemonic(ctx):

    rule = ctx.attr._rule
    mnemonic = None

    if rule in ["std_ocamlc_byte", "std_ocamlopt_byte",
                  "std_ocamlopt_opt", "std_ocamlc_opt"]:
        mnemonic = "LinkStdCompiler"

    elif rule in ["ocamloptx_byte", "ocamloptx_optx",
                  "ocamlc_optx", "ocamlopt.optx"]:
        mnemonic = "LinkFlambdaCompiler"

    elif rule in ["boot_ocamlc_byte", "boot_ocamlopt_byte",
                  "boot_ocamlopt_opt", "boot_ocamlc_opt"]:
        mnemonic = "LinkBootCompiler"

    elif rule in ["test_ocamlc_byte", "test_ocamlopt_byte",
                  "test_ocamlopt_opt", "test_ocamlc_opt"]:
        mnemonic = "LinkTestCompiler"

    elif rule in ["build_tool_vm", "ocaml_tool_vm"]:
        mnemonic = "LinkToolVm"

    elif rule in ["build_tool_sys", "ocaml_tool_sys"]:
        mnemonic = "LinkToolSys"

    elif rule in ["ocaml_tool_r"]:
        mnemonic = "LinkTool"

    elif rule in ["test_executable"]:
        ## all [sv][sv]_test_executable rules use this rule name
        mnemonic = "LinkTestExecutable"
    elif rule in ["test_vv_executable"]:
        mnemonic = "LinkVvTestExecutable"
    elif rule in ["test_ss_executable"]:
        mnemonic = "LinkSsTestExecutable"

    elif rule in ["compiler_module", "build_module",
                  "stdlib_module", "stdlib_internal_module",
                  "kernel_module",
                  "tool_module",
                  "ns_module",
                  "boot_module"]:
        mnemonic = "CompileModule"

    elif rule in ["test_module"]:
        mnemonic = "CompileTestModule"

    elif rule in ["test_expect_module"]:
        mnemonic = "CompileTestExpectModule"

    elif rule in ["test_infer_signature"]:
        mnemonic = "InferSignature"

    elif rule in ["compiler_signature",
                  "stdlib_signature", "stdlib_internal_signature",
                  "kernel_signature",
                  "tool_signature",
                  "ns_signature"]:
        mnemonic = "CompileSig"

    elif rule in ["test_signature"]:
        mnemonic = "CompileTestSig"

    elif rule in ["boot_archive", "test_archive"]:
        mnemonic = "ArchiveLib"

    elif rule in ["expect_test", "lambda_expect_test",
                  "compile_fail_test"]:
        mnemonic = "Testing"

    elif rule == "inline_test":
        mnemonic = "InlineTest"

    elif rule in ["run_ocamllex"]:
        mnemonic = "Running ocamllex"

    elif rule == "compiler_library":
        if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
            mnemonic = "Archiving compiler lib"
        else:
            mnemonic = "Packaging compiler lib"
    elif rule == "stdlib_library":
        if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
            mnemonic = "Archiving stdlib library"
        else:
            mnemonic = "Packaging stdlib library"
    elif rule == "test_library":
        if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
            mnemonic = "Archiving test lib"
        else:
            mnemonic = "Packaging test lib"
    else:
        fail(rule)

    return mnemonic

###########################
def get_build_executor(tc):

    debug = True
    if debug:
        print("get_build_executor")

    config_executor = tc.config_executor[BuildSettingInfo].value
    config_emitter  = tc.config_emitter[BuildSettingInfo].value

    if debug:
        print("config_executor %s" % config_executor)
        print("config_emitter  %s" % config_emitter)

    if tc.protocol == "dev":
        build_executor = "opt"
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
    elif (config_executor == "boot" and config_emitter == "boot"):
        build_executor = "vm"
    elif (config_executor == "baseline" and config_emitter == "baseline"):
        build_executor = "vm"
    elif (config_executor == "vm" and config_emitter == "vm"):
        build_executor = "vm"
    elif (config_executor == "vm" and config_emitter == "sys"):
        build_executor = "vm"
    elif (config_executor == "sys" and config_emitter == "sys"):
        ## ss always built by vs (ocamlopt.byte)
        build_executor = "vm"
    elif (config_executor == "sys" and config_emitter == "vm"):
        ## sv built by ss
        build_executor = "sys"

    return build_executor

##############################
## what we need from the config:
# for all targets:
#   * tool to run - ocamlrun + tool, or just tool
#   # tool == either ocamlcc or ocamllex?
# for modules, archives, sigs:
#   * type of output: .cmo/.cmx, .cma/.cmxa, .cmi
# for executables: target executor, to control:
#   * selection of runtime (libcamlrun/libasmrun)
#   * inclusion of camlheaders

# def configure_action(ctx, tc):
#     executable = None
#     if tc.protocol == "dev":
#         ocamlrun = None
#         effective_compiler = tc.compiler
#     else:
#         ## tc.compiler runfiles: bottom element is always ocamlrun
#         ocamlrun = tc.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
#         ## most recently built compiler:
#         effective_compiler = tc.compiler[DefaultInfo].files_to_run.executable

#     build_executor = get_build_executor(tc)
#     # print("xBX: %s" % build_executor)
#     # print("xTX: %s" % config_executor)
#     # print("xef: %s" % effective_compiler)

#     if build_executor == "vm":
#         executable = ocamlrun
#         args.add(effective_compiler.path)
#         if config_executor in ["sys"]:
#             ext = ".cmx"
#         else:
#             ext = ".cmo"
#     else:
#         executable = effective_compiler
#         ext = ".cmx"

#     return (ocamlrun, executable,
#             build_executor, target_executor)

###############################
def progress_msg(workdir, ctx):
    rule = ctx.attr._rule

    if "//toolchain/type:boot" in ctx.toolchains:
        tc = ctx.toolchains["//toolchain/type:boot"]
    else:
        tc = ctx.toolchains["//toolchain/type:ocaml"]

    mnemonic = rule_mnemonic(ctx)

    cmode = ctx.var["COMPILATION_MODE"]
    if cmode == "fastbuild": cmode = "fb"

    protocol = ctx.attr._protocol[BuildSettingInfo].value
    if protocol == "std":
        lbrack = "<"
        rbrack = ">"
    elif protocol == "boot":
        lbrack = "<<"
        rbrack = ">>"
    elif protocol == "test":
        lbrack = "["
        rbrack = "]"
    elif protocol in ["fb"]:
        lbrack = "[["
        rbrack = "]]"
    elif protocol in ["tool"]: # ie build_tool
        lbrack = "("
        rbrack = ")"
    else:
        lbrack = "??"
        rbrack = "??"

    if tc.config_executor == "sys":
        x = "opt"
        if tc.config_emitter == "sys":
            em = "ocamlopt"
        else:
            em = "ocamlc"
    else:
        x = "byte"
        if tc.config_emitter == "sys":
            em = "ocamlopt"
        else:
            em = "ocamlc"

    flambda = tc.flambda[BuildSettingInfo].value
    msg = "{m} {lbrack}{flambda}{c}{rbrack}{mnemonic}: {ws}//{pkg}:{tgt} {rule}".format(
        m   = cmode,
        lbrack = lbrack,
        flambda = "!" if flambda else "",
        c   = tc.compiler[DefaultInfo].files_to_run.executable.basename,
        x   = x,
        em  = em,
        rbrack = rbrack,
        # wd  = workdir,
        # m  = ctx.attr._compilation_mode,
        rule= rule,
        ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
        pkg = ctx.label.package,
        tgt=ctx.label.name,
        mnemonic = mnemonic
    )
    return msg
