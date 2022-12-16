load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

############################################################
def get_build_executor(tc):

    debug = True
    if debug:
        print("get_build_executor")

    target_executor = tc.target_executor[BuildSettingInfo].value
    target_emitter  = tc.target_emitter[BuildSettingInfo].value
    config_executor = tc.config_executor[BuildSettingInfo].value
    config_emitter  = tc.config_emitter[BuildSettingInfo].value

    if debug:
        print("target_executor %s" % target_executor)
        print("target_emitter  %s" % target_emitter)
        print("config_executor %s" % config_executor)
        print("config_emitter  %s" % config_emitter)

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

###############################
def progress_msg(workdir, ctx):
    rule = ctx.attr._rule
    if rule in ["ocaml_compiler", "build_tool", "ocaml_lex", "ocaml_tool", "test_executable"]:
        action = "Linking"
    elif rule in ["compiler_module", "build_module", "stdlib_module", "stdlib_internal_module", "kernel_module", "test_module", "tool_module", "ns_module"]:
        action = "Compiling"
    elif rule in ["compiler_signature", "stdlib_signature", "stdlib_internal_signature", "kernel_signature", "test_signature", "tool_signature", "ns_signature"]:
        action = "Compiling"
    elif rule in ["boot_archive", "test_archive"]:
        action = "Archiving"
    elif rule in ["ocaml_test", "expect_test", "lambda_expect_test",
                  "compile_fail_test"]:
        action = "Testing"
    elif rule in ["lex"]:
        action = "Lexing"
    else:
        fail(rule)

    msg = "{m} [{wd}]: {ws}//{pkg}:{tgt} {action} {rule}".format(
        m   = ctx.var["COMPILATION_MODE"],
        wd  = workdir,
        # m  = ctx.attr._compilation_mode,
        rule= rule,
        ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
        pkg = ctx.label.package,
        tgt=ctx.label.name,
        action = action
    )
    return msg
