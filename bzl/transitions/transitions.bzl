load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

##############################################
def _tc_target_transitions(settings, attr, debug):

    ## we use the CLI string flags in //config/...
    ## to set string settings in //toolchain/...
    # target_executor = settings["//toolchain/target/executor"]
    # target_emitter  = settings["//toolchain/target/emitter"]
    config_executor = settings["//config/target/executor"]
    config_emitter  = settings["//config/target/emitter"]
    # target_runtime  = settings["//toolchain:runtime"]

    # compiler = settings["//toolchain:compiler"]
    # lexer = settings["//toolchain:lexer"]

    # build_host  = settings["//command_line_option:host_platform"]
    # extra_execution_platforms = settings["//command_line_option:extra_execution_platforms"]

    # target_host = settings["//command_line_option:platforms"]

    # stage = int(settings["//config/stage"])

    if debug:
        # print("//config/stage: %s" % stage)
        # print("//toolchain/target/executor: %s" % settings[
        #     "//toolchain/target/executor"])
        # print("//toolchain/target/emitter:  %s" % settings[
        #     "//toolchain/target/emitter"])
        print("//config/target/executor: %s" % settings[
            "//config/target/executor"])
        print("//config/target/emitter:  %s" % settings[
            "//config/target/emitter"])

    # host_compilation_mode = "opt"
    # compilation_mode = "opt"
    # runtime  = "//runtime:ocamlrun"

    ## initial config: config settings passed on cli, toolchain
    ## configs default to unspecified

    if config_executor == "boot":
        return config_executor, config_emitter

    elif (config_executor == "boot"): #and config_emitter == "boot"):
        config_executor = "baseline"
        config_emitter  = "baseline"
    elif (config_executor == "baseline"):
        config_executor = "boot"
        config_emitter  = "boot"
    elif (config_executor == "vm" and config_emitter == "vm"):
        config_executor = "baseline"
        config_emitter  = "baseline"
    elif (config_executor == "vm" and config_emitter == "sys"):
        config_executor = "vm"
        config_emitter = "vm"
    elif (config_executor == "sys" and config_emitter == "sys"):
        config_executor = "vm"
        config_emitter  = "sys"
    elif (config_executor == "sys" and config_emitter == "vm"):
        config_executor = "sys"
        config_emitter  = "sys"
    else:
        fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    return (config_executor, config_emitter)

##############################################
def tc_compiler_out_transition_impl(settings, attr, debug):

    config_executor, config_emitter = _tc_target_transitions(settings, attr, debug)

    # compiler = settings["//toolchain:compiler"]
    # lexer = settings["//toolchain:lexer"]

    if debug:
        print("//toolchain:compiler:  %s" % settings["//toolchain:compiler"])
        # print("//toolhchain:runtime:     %s" % target_runtime)
        # print("attr.target_executor: %s" % attr.target_executor)

    if config_executor == "boot":
        print("ctxn CC TRANSITION")
        return {}
    elif (config_executor == "boot"): #and config_emitter == "boot"):
        print("ctxn BOOT TRANSITION")
        compiler = "//boot:ocamlc.boot"
    elif (config_executor == "baseline"):
        print("ctxn BASELINE TRANSITION")
        compiler = "//boot:ocamlc.boot"
    elif (config_executor == "vm" and config_emitter == "vm"):
        print("ctxn VM-VM TRANSITION")
        compiler = "//bin:ocamlcc"
    elif (config_executor == "vm" and config_emitter == "sys"):
        print("ctxn VM-SYS TRANSITION")
        compiler = "//bin:ocamlcc"
    elif (config_executor == "sys" and config_emitter == "sys"):
        print("ctxn SYS-SYS TRANSITION")
        compiler = "//bin:ocamlcc"
    elif (config_executor == "sys" and config_emitter == "vm"):
        print("ctxn SYS-VM TRANSITION")
        compiler = "//bin:ocamlcc"
    else:
        fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    if debug:
        # print("setting //toolchain/target/executor: %s" % target_executor)
        # print("setting //toolchain/target/emitter: %s" % target_emitter)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        print("setting //toolchain:compiler %s" % compiler)
        # print("setting //toolchain:lexer %s" % lexer)

    return {
        # "//command_line_option:host_compilation_mode": "opt",
        # "//command_line_option:compilation_mode": "opt",

        # "//toolchain/target/executor": target_executor,
        # "//toolchain/target/emitter" : target_emitter,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,

        "//toolchain:compiler": compiler,
        # "//toolchain:lexer"   : lexer,
        # "//toolchain:runtime" : runtime,
    }

##############################################
def tc_lexer_out_transition_impl(settings, attr, debug):

    config_executor, config_emitter = _tc_target_transitions(settings, attr, debug)

    # compiler = settings["//toolchain:compiler"]
    # lexer = settings["//toolchain:lexer"]

    if debug:
        print("//toolchain:lexer:  %s" % settings["//toolchain:lexer"])

    if config_executor == "boot":
        print("lextxn CC TRANSITION")
        return {}
    elif (config_executor == "boot"): #and config_emitter == "boot"):
        print("lextxn BOOT TRANSITION")
        lexer    = "//boot:ocamllex.boot"
    elif (config_executor == "baseline"):
        print("lextxn BASELINE TRANSITION")
        lexer    = "//boot:ocamllex.boot"
    elif (config_executor == "vm" and config_emitter == "vm"):
        print("lextxn VM-VM TRANSITION")
        lexer    = "//lex:ocamllex"
    elif (config_executor == "vm" and config_emitter == "sys"):
        print("lextxn VM-SYS TRANSITION")
        lexer    = "//lex:ocamllex"
    elif (config_executor == "sys" and config_emitter == "sys"):
        print("lextxn SYS-SYS TRANSITION")
        lexer    = "//lex:ocamllex"
    elif (config_executor == "sys" and config_emitter == "vm"):
        print("lextxn SYS-VM TRANSITION")
        lexer    = "//lex:ocamllex"
    else:
        fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    if debug:
        # print("setting //toolchain/target/executor: %s" % target_executor)
        # print("setting //toolchain/target/emitter: %s" % target_emitter)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        # print("setting //toolchain:compiler %s" % compiler)
        print("setting //toolchain:lexer %s" % lexer)

    return {
        # "//command_line_option:host_compilation_mode": "opt",
        # "//command_line_option:compilation_mode": "opt",

        # "//toolchain/target/executor": target_executor,
        # "//toolchain/target/emitter" : target_emitter,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,

        # "//toolchain:compiler": compiler,
        "//toolchain:lexer"   : lexer,
        # "//toolchain:runtime" : runtime,
    }

##############################################
def tc_runtime_out_transition_impl(settings, attr, debug):

    config_executor, config_emitter = _tc_target_transitions(settings, attr, debug)

    if debug:
        print("//toolchain:runtime: %s" % settings["//toolchain:runtime"])

    if config_executor == "boot":
        print("rttxn CC TRANSITION")
        return {}
    elif (config_executor == "boot"): #and config_emitter == "boot"):
        print("rttxn BOOT TRANSITION")
        runtime  = "//runtime:camlrun"
    elif (config_executor == "baseline"):
        print("rttxn BASELINE TRANSITION")
        runtime  = "//runtime:camlrun"
    elif (config_executor == "vm" and config_emitter == "vm"):
        print("rttxn VM-VM TRANSITION")
        runtime  = "//runtime:camlrun"
    elif (config_executor == "vm" and config_emitter == "sys"):
        print("rttxn VM-SYS TRANSITION")
        runtime  = "//runtime:asmrun"
    elif (config_executor == "sys" and config_emitter == "sys"):
        print("rttxn SYS-SYS TRANSITION")
        runtime  = "//runtime:asmrun"
    elif (config_executor == "sys" and config_emitter == "vm"):
        print("rttxn SYS-VM TRANSITION")
        runtime  = "//runtime:asmrun"
    else:
        fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    if debug:
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        print("setting //toolchain:runtime %s" % runtime)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:runtime"     : runtime
    }

##############################################
def tc_mustache_transition_impl(settings, attr, debug):
    print("tc_mustache_transition_impl")

    return {
        "//command_line_option:host_compilation_mode": "opt",
        "//command_line_option:compilation_mode": "opt",

        "//toolchain/target/executor": "boot",
        "//toolchain/target/emitter" : "boot",

        "//config/target/executor": "boot",
        "//config/target/emitter" : "boot",

        # "//toolchain:compiler" : "//boot:ocamlc.boot",
        # "//toolchain:lexer"    : "//boot:ocamllex.boot",
        # "//toolchain:runtime"  : "//runtime:camlrun",
    }

##############################################
def tc_boot_in_transition_impl(settings, attr, debug):
    print("tc_boot_in_transition_impl")

    return {
        "//command_line_option:host_compilation_mode": "opt",
        "//command_line_option:compilation_mode": "opt",

        "//toolchain/target/executor": "boot",
        "//toolchain/target/emitter" : "boot",

        "//config/target/executor": "boot",
        "//config/target/emitter" : "boot",

        "//toolchain:compiler" : "//boot:ocamlc.boot",
        "//toolchain:lexer"    : "//boot:ocamllex.boot",
        "//toolchain:runtime"  : "//runtime:camlrun",
    }

#####################################################
## reset_config_transition
# reset stage to 0 (_boot) so runtime is only built once
def reset_config_transition_impl(settings, attr):
    print("reset_config_transition: %s" % attr.name)

    return {
        # "//toolchain/target/executor": "boot",
        # "//toolchain/target/emitter" : "boot",

        "//config/target/executor": "boot",
        "//config/target/emitter" : "boot",

        "//toolchain:compiler" : "//boot:ocamlc.boot",
        "//toolchain:lexer"    : "//boot:ocamllex.boot",
    }

##############################################
def ocaml_tool_in_transition_impl(settings, attr, debug):

    ## we use the CLI string flags in //config/...
    ## to set string settings in //toolchain/...
    target_executor = settings["//toolchain/target/executor"]
    target_emitter  = settings["//toolchain/target/emitter"]
    config_executor = settings["//config/target/executor"]
    config_emitter  = settings["//config/target/emitter"]
    # target_runtime  = settings["//toolchain:runtime"]

    compiler = settings["//toolchain:compiler"]
    lexer = settings["//toolchain:lexer"]

    # build_host  = settings["//command_line_option:host_platform"]
    # extra_execution_platforms = settings["//command_line_option:extra_execution_platforms"]

    # target_host = settings["//command_line_option:platforms"]

    # stage = int(settings["//config/stage"])

    if debug:
        # print("//config/stage: %s" % stage)
        print("//toolchain/target/executor: %s" % settings[
            "//toolchain/target/executor"])
        print("//toolchain/target/emitter:  %s" % settings[
            "//toolchain/target/emitter"])
        print("//config/target/executor: %s" % settings[
            "//config/target/executor"])
        print("//config/target/emitter:  %s" % settings[
            "//config/target/emitter"])

        print("//toolchain:compiler:  %s" % settings["//toolchain:compiler"])
        print("//toolchain:lexer:  %s" % settings["//toolchain:lexer"])
        print("//toolchain:runtime:  %s" % settings["//toolchain:runtime"])

        # print("//toolhchain:runtime:     %s" % target_runtime)
        # print("attr.target_executor: %s" % attr.target_executor)
        # print("//command_line_option:host_platform: %s" % build_host)
        # print("//command_line_option:extra_execution_platforms: %s" % extra_execution_platforms)
        # print("//command_line_option:platforms: %s" % target_host)


    ## avoid rebuilding _boot/ocamlc.byte: ??

    host_compilation_mode = "opt"
    compilation_mode = "opt"
    # runtime  = "//runtime:ocamlrun"

    ## initial config: config settings passed on cli, toolchain
    ## configs default to unspecified

    if config_executor == "boot":

        print("CC TRANSITION")
        return {}

    elif (config_executor == "boot"): #and config_emitter == "boot"):
        print("BOOT TRANSITION")
        compilation_mode = "opt"
        config_executor = "baseline"
        config_emitter  = "baseline"

        # if (compiler == "//boot:ocamlc.boot" and
        #     lexer    == "//boot:ocamllex.boot"):
        #     compiler = "//boot:ocamlc.boot"
        #     lexer    = "//boot:ocamllex.boot"
        #     runtime  = "//runtime:camlrun"
        #     # return{}
        # else:
        compiler = "//boot:ocamlc.boot"
        lexer    = "//boot:ocamllex.boot"
        runtime  = "//runtime:camlrun"

    elif (config_executor == "baseline"):
        print("BASELINE transition")
        config_executor = "boot"
        config_emitter  = "boot"
        compiler = "//boot:ocamlc.boot"
        lexer    = "//boot:ocamllex.boot"
        runtime  = "//runtime:camlrun"
    #     fail("bad config_emitter: %s" % config_emitter)

    elif (config_executor == "vm" and config_emitter == "vm"):
        print("VM-VM TRANSITION")
        config_executor = "baseline"
        config_emitter  = "baseline"
        ## these just prevent circular dep?
        ## need to set before recurring, otherwise we get a dep cycle
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"
        runtime  = "//runtime:asmrun"
        # runtime  = "//runtime:camlrun"
        # compiler = "//boot:ocamlc.boot"
        # lexer    = "//boot:ocamllex.boot"

    elif (config_executor == "vm" and config_emitter == "sys"):
        print("VM-SYS transition")
        config_executor = "vm"
        config_emitter = "vm"
        # target_executor = "boot"
        # target_emitter = "boot"
        # target_executor = "vm"
        # target_emitter = "vm"
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"
        runtime  = "//runtime:asmrun"

    elif (config_executor == "sys" and config_emitter == "sys"):
        print("SYS-SYS transition")
        config_executor = "vm"
        config_emitter  = "sys"
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"
        runtime  = "//runtime:asmrun"

    elif (config_executor == "sys" and config_emitter == "vm"):
        print("SYS-VM transition")
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"
        runtime  = "//runtime:asmrun"


    else:
        fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    if debug:
        # print("setting //toolchain/target/executor: %s" % target_executor)
        # print("setting //toolchain/target/emitter: %s" % target_emitter)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        print("setting //toolchain:compiler %s" % compiler)
        print("setting //toolchain:lexer %s" % lexer)

    return {
        # "//command_line_option:host_compilation_mode": "opt",
        # "//command_line_option:compilation_mode": "opt",

        # "//toolchain/target/executor": target_executor,
        # "//toolchain/target/emitter" : target_emitter,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
    }

