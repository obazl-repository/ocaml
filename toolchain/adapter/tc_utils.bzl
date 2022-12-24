load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo")

load("//toolchain:transitions.bzl", "tool_out_transition")

load("//bzl/transitions:tc_transitions.bzl",
     # "tc_compiler_out_transition",
     # "tc_lexer_out_transition",
     "tc_runtime_out_transition")

#################
def tc_build_executor(ctx):
    debug = False
    if debug:
        print("tc.build_executor: %s" % ctx.label)

    ## NB: "config" means target (//config/target/[executor|emitter])
    t_executor = ctx.attr.config_executor[BuildSettingInfo].value
    t_emitter  = ctx.attr.config_emitter[BuildSettingInfo].value
    if debug:
        print("config_executor: %s" % t_executor)
        print("config_emitter: %s" % t_emitter)
        print("tc.compiler: %s" % ctx.attr.compiler)

    if False: # ctx.attr.dev[BuildSettingInfo].value:
        build_executor = t_executor
    else:
        # we can always infer build_emitter from target_executor
        # in general we cannot so infer build_executor.
        # however in this controlled environment we always know
        # how target executor/emitter combinations are built,
        # so we can infer build executor from that pair.

        if debug:
            print("t_executor: %s" % t_executor)
            print("t_emitter: %s" % t_emitter)

        stack = "boot"  ## FIXME: use //config/stack:fixed-point?
        baseline = False

        if (t_executor == "boot" and t_emitter == "boot"):
            build_executor = "vm"
        elif (t_executor == "baseline" and t_emitter == "baseline"):
            build_executor = "vm"

        elif (t_executor == "vm" and t_emitter == "vm"):
            # target: ocamlc.byte
            build_executor = "vm"

        elif (t_executor == "vm" and t_emitter == "sys"):
            # target: ocamlopt.byte
            build_executor = "vm"

        elif (t_executor == "sys" and t_emitter == "sys"):
            # target: ocamlopt.opt
            build_executor = "sys"
            # if stack == "fixed-point":
            #     if baseline:
            #         # _baseline/ocamlopt.opt built by _fp/ocamlopt.byte
            #         build_executor = "vm"
            #     else:
            #         # _fp/ocamlopt.opt built by _baseline/ocamlopt.opt
            #         build_executor = "sys"
            # else:
            #     # built by ocamlopt.byte
            #     if ctx.attr.dev[BuildSettingInfo].value:
            #         build_executor = "sys"
            #     else:
            #         build_executor = "vm"

        elif (t_executor == "sys" and t_emitter == "vm"):
            # target: ocamlc.opt
            if stack == "fixed-point":
                # _fp/ocamlc.opt built by _fp/ocamlopt.opt
                build_executor = "sys"
            else:
                # ocamlc.opt built by ocamlopt.byte
                # FIXME: implement boot, fixed-point protocols
                build_executor = "sys"  # legacy, should be vm

        else:
            build_executor = "ERROR"

    # print("inferred build executor == %s" % build_executor)
    return build_executor

#################
def tc_tool_arg(ctx):

    debug = False

    tc_config_executor = ctx.attr.config_executor[BuildSettingInfo].value

    if debug:
        print("TC.TOOL_ARG: %s" % ctx.label)
        print("tc.build_executor: %s" % tc_build_executor(ctx))
        print("tc.config_executor: %s" % tc_config_executor)

    if ctx.file.compiler.basename.endswith(".opt"):
        return None
    else:
        return ctx.file.compiler

    if type(ctx.attr.compiler) == "list":
        tcc = ctx.attr.compiler[0][DefaultInfo].files_to_run.executable
    else:
        tcc = ctx.attr.compiler[DefaultInfo].files_to_run.executable
    if debug:
        print("tc.compiler: %s" % tcc.path)

    if ctx.attr.protocol[BuildSettingInfo].value == "dev":
        if tc_build_executor(ctx) in ["boot", "baseline", "vm"]:
        # if tc_config_executor:
            return tcc
        else:
            return None
    else:
        # if ctx.attr.config_executor[BuildSettingInfo].value in ["boot", "baseline", "vm"]:
        if tc_build_executor(ctx) in ["boot", "baseline", "vm"]:
            # most recently built compiler
            print("returning TARG vm: %s" % tcc)
            return tcc
        else:
            # return tc.compiler[DefaultInfo].files_to_run.executable
            print("returning TARG sys: None")
            return None

###################
## returns file object
def tc_executable(ctx, tool):

    debug = False

    if debug:
        print("ENTRY tc_executable for tool: %s" % tool)
        print("tc.name: %s" % ctx.attr.name)

    if (ctx.file.compiler.basename.endswith(".byte")
        or ctx.file.compiler.basename.endswith(".boot")
        or ctx.file.compiler.basename.endswith(".baseline")
        or ctx.file.compiler.basename == ("ocamlc")):
        return ctx.file.ocamlrun
    elif ctx.file.compiler.basename.endswith(".opt"):
        return ctx.file.compiler
    else:
        fail("bad compiler basename: %s" % ctx.file.compiler.basename)

    tc_config_executor = ctx.attr.config_executor[BuildSettingInfo].value

    if ctx.attr.protocol[BuildSettingInfo].value == "dev":
        if tool == "compiler":
            ## default: sys mode
            # if tc_config_executor in ["boot", "baseline", "vm"]:
            if tc_build_executor(ctx) in ["boot", "baseline", "vm"]:
                ocamlrun =  ctx.file.ocamlrun
                return ocamlrun
            else:
                return ctx.file.compiler

            # if tc_build_executor(ctx) in ["boot", "baseline", "vm"]:
            #     ocamlrun =  ctx.file.ocamlrun
            #     return ocamlrun
            # else:
            #     return ctx.file.compiler
        else:
            if ctx.attr.config_executor in ["boot", "baseline", "vm"]:
                ocamlrun =  ctx.file.ocamlrun
                return ocamlrun
            # else:
            #     return ctx.file.lexer
    else:
        ## tc.compiler runfiles: bottom element is always ocamlrun
        # if tc_build_executor(ctx) in ["boot", "baseline", "vm"]:
        if (ctx.file.compiler.basename.endswith(".byte")
            or ctx.file.compiler.basename.endswith(".boot")):
            return ctx.file.ocamlrun
            # if type(ctx.attr.compiler) == "list":
            #     ## built compiler, transitioned

            #     xocamlrun =  ctx.attr.compiler[0][DefaultInfo].default_runfiles.files.to_list()[0]
            #     if debug:
            #         print("XOCAMLRUN: %s" % xocamlrun)
            #     return xocamlrun

            # else:
            #     ## boot compiler
            #     if debug:
            #         print("TX: %s" % ctx.attr.compiler[DefaultInfo])
            #     ocamlrun = ctx.attr.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
            #     if debug:
            #         print("OCAMLRUN: %s" % ocamlrun)
                # return ocamlrun
        else:
            print("lbl: %s" % ctx.label)
            print("ocamlrun: %s" % ctx.file.ocamlrun)
            # fail("XXXXXXXXXXXXXXXX")

            if debug:
                print("returning ctx.file.compiler: %s" % ctx.file.compiler)
            return ctx.file.compiler

####################
def tc_compiler(ctx):

    if type(ctx.attr.compiler) == "list":
        # because of transitions
        return ctx.attr.compiler[0]
    else:
        return ctx.attr.compiler

###################
def tc_workdir(ctx):

    protocol = ctx.attr.protocol[BuildSettingInfo].value

    if protocol == "test":
        workdir = "_test"

    config_executor = ctx.attr.config_executor[BuildSettingInfo].value
    config_emitter  = ctx.attr.config_emitter[BuildSettingInfo].value

    compiler = ctx.file.compiler
    if compiler.basename == "ocamlc.boot":
        return "_boot/"
    else:
        return paths.basename(compiler.dirname) + "_" + compiler.basename.replace(".", "_") + "/"

    if ctx.file.compiler.path == "bin:ocamlc.byte":
        if protocol == "boot":
            workdir = "_boot/"
        else:
            workdir = "_baseline/"

    elif protocol == "boot":
        workdir = "_boot/"

    elif protocol == "baseline":
        workdir = "_baseline/"

    elif (config_executor == "boot"):
        workdir = "_xboot/"
        # fail("WHY BOOT?")

    elif (config_executor == "baseline"):
        workdir = "_xbaseline/"

    # elif (config_executor == "vm" and config_emitter == "boot"):
    #     if tc.protocol == "dev":
    #         # dev mode, passing only --//config/target/executor=vm
    #         workdir = "_ocamlc.opt/"
    #     else:
    #         workdir = "_ocamlc.byte/"

    elif (config_executor == "vm" and config_emitter == "vm"):
        workdir = "_xocamlc.byte/"

    elif (config_executor == "vm" and config_emitter == "sys"):
        workdir = "_ocamlopt.byte/"

    # elif (config_executor == "sys" and config_emitter == "boot"):
    #     if tc.protocol == "dev":
    #         # dev mode, passing only --//config/target/executor=sys
    #         workdir = "_ocamlopt.opt/"
    #     else:
    #         workdir = "_ocamlc.opt/"

    elif (config_executor == "sys" and config_emitter == "vm"):
        workdir = "_ocamlc.opt/"

    elif (config_executor == "sys" and config_emitter == "sys"):
        workdir = "_ocamlopt.opt/"

    else:
        print("config_executor: %s" % config_executor)
        print("config_emitter: %s" % config_emitter)
        fail("BAD CONFIG")

    # workdir = ctx.attr.name + "/"

    return workdir
