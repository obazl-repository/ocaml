##############################################
def _ocaml_stdlib_cmxa_in_transition_impl(settings, attr):

    debug = False

    protocol = settings["//config/build/protocol"]

    if protocol == "preboot":
        return {}

    return {
        "//config/target/executor": "vm",
        "//config/target/emitter" : "sys",

        "//toolchain:compiler": "//bin:ocamlopt.byte",
        "//toolchain:runtime" : settings["//toolchain:runtime"],
    }


############################################
ocaml_stdlib_cmxa_in_transition = transition(
    implementation = _ocaml_stdlib_cmxa_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)


##############################################
def _tc_target_transitions(settings, attr, debug):
    debug = False
    if debug: print("tc_target_transitions")

    ## we use the CLI string flags in //config/...
    ## to set string settings in //toolchain/...

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
        # base case - no change
        return config_executor, config_emitter
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
def _ocaml_tc_compiler_out_transition_impl(settings, attr):
    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = False

    protocol = settings["//config/build/protocol"]

    config_executor, config_emitter = _tc_target_transitions(settings, attr, debug)

    if debug:
        print("ENTRY: ocmal_tc_compiler_out_transition")
        print("tc name: %s" % attr.name)
        print("protocol: %s" % protocol)
        print("config_executor: %s" % config_executor)
        print("config_emitter: %s" % config_emitter)
        print("runtime:  %s" % settings["//toolchain:runtime"])

    if protocol == "preboot":
        return {}

    if protocol == "boot":
        return {}

    if protocol == "baseline":
        return {}

    if protocol == "test":
        # print("identity txn ")
        return {}

    config_executor, config_emitter = _tc_target_transitions(settings, attr, debug)

    # compiler = settings["//toolchain:compiler"]
    # lexer = settings["//toolchain:lexer"]

    if debug:
        print("//toolchain:compiler:  %s" % settings["//toolchain:compiler"])
    if config_executor == "boot":
        print("ctxn BASE CASE")
        # compiler = "//boot:ocamlc.boot"
        fail()
        # lexer    = "//boot:ocamllex.boot"
    elif (config_executor == "baseline"):
        print("ctxn BASELINE TRANSITION")
        compiler = "//bin:ocamlcc"
        # lexer    = "//lex:ocamllex"
    else:
        compiler = "//bin:ocamlcc"
        # lexer    = "//lex:ocamllex"


    # elif (config_executor == "vm" and config_emitter == "vm"):
    #     print("ctxn VM-VM TRANSITION (ocamlopt.byte > ocamlc.byte)")
    #     compiler = "//bin:ocamlcc"

    # elif (config_executor == "vm" and config_emitter == "sys"):
    #     print("ctxn VM-SYS TRANSITION")
    #     compiler = "//bin:ocamlcc"

    # elif (config_executor == "sys" and config_emitter == "sys"):
    #     print("ctxn SYS-SYS TRANSITION")
    #     compiler = "//bin:ocamlcc"

    # elif (config_executor == "sys" and config_emitter == "vm"):
    #     print("ctxn SYS-VM TRANSITION")
    #     compiler = "//bin:ocamlcc"

    # else:
    #     fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    if debug:
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        print("setting //toolchain:compiler %s" % compiler)
        # print("setting //toolchain:lexer %s" % lexer)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,

        "//toolchain:compiler": compiler,
        # "//toolchain:lexer"   : lexer,
        "//toolchain:runtime" : settings["//toolchain:runtime"],
        "//toolchain:cvt_emit" : settings["//toolchain:cvt_emit"]
    }

#####################################################
#######################
ocaml_tc_compiler_out_transition = transition(
    implementation = _ocaml_tc_compiler_out_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit",
    ]
)

################################################################
## prot_topleve, prot_boot: used by ocaml_in_transition
def prot_toplevel(config_executor, config_emitter):
    protocol = "boot"
    if config_executor == "sys":
        if config_emitter == "sys":
            # use vm>sys to build sys>sys
            # config_executor = "vm"
            compiler = "//bin:ocamlopt.opt"
            runtime  = "//runtime:asmrun"
        elif config_emitter == "vm":
            # use sys>sys to build sys>vm
            # config_emitter = "sys"
            compiler = "//bin:ocamlc.opt"
            runtime  = "//runtime:asmrun"
        else:
            fail("executor sys, bad emitter: %s" % config_emitter)
    elif config_executor in ["boot", "vm"]:
        # config_executor = "vm"
        if config_emitter in ["boot", "vm"]:
            # config_emitter = "vm"
            # use boot ocamlc to build vm>vm
            # compiler = "//boot:ocamlc.boot"
            fail()
            runtime  = "//runtime:camlrun"
        elif config_emitter == "sys":
            # use vm>vm to build vm>sys
            # config_emitter = "vm"
            compiler = "//bin:ocamlopt.byte"
            runtime  = "//runtime:camlrun"
        else:
            fail("executor sys, bad emitter: %s" % config_emitter)
    else:
        fail("bad executor: %s" % config_executor)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

################
def prot_boot(config_executor, config_emitter):
    protocol = "boot"
    if config_executor == "sys":
        if config_emitter == "sys":
            # use vm>sys to build sys>sys
            # config_executor = "vm"
            compiler = "//boot:ocamlopt.opt"
            runtime  = "//runtime:asmrun"
        elif config_emitter == "vm":
            # use sys>sys to build sys>vm
            # config_emitter = "sys"
            compiler = "//boot:ocamlc.opt"
            runtime  = "//runtime:asmrun"
        else:
            fail("executor sys, bad emitter: %s" % config_emitter)
    elif config_executor in ["boot", "vm"]:
        # config_executor = "vm"
        if config_emitter in ["boot", "vm"]:
            # config_emitter = "vm"
            # use boot ocamlc to build vm>vm
            # compiler = "//boot:ocamlc.boot"
            fail()
            runtime  = "//runtime:camlrun"
        elif config_emitter == "sys":
            # use vm>vm to build vm>sys
            # config_emitter = "vm"
            compiler = "//boot:ocamlopt.byte"
            runtime  = "//runtime:camlrun"
        else:
            fail("executor sys, bad emitter: %s" % config_emitter)
    else:
        fail("bad executor: %s" % config_executor)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

##########################################################
def _ocaml_in_transition_impl(settings, attr):
    debug = False

    protocol        = settings["//config/build/protocol"]

    if protocol == "preboot":
        return {}

    config_executor = settings["//config/target/executor"]
    config_emitter  = settings["//config/target/emitter"]
    compiler        = settings["//toolchain:compiler"]

    if debug:
        print("ocaml_in_transition")
        print("protocol: %s" % protocol)
        print("config_executor: %s" % config_executor)
        print("config_emitter:  %s" % config_emitter)
        print("compiler:        %s" % compiler)

    if protocol == "unspecified": ## building from cmd line
        return prot_toplevel(config_executor, config_emitter)
    elif protocol == "boot":
        return prot_boot(config_executor, config_emitter)
    else:
        fail("Protocol not yet supported: %s" % protocol)

################################################################
ocaml_in_transition = transition(
    implementation = _ocaml_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocaml_tool_vm_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocaml_tool_vm_in_transition")

    ## always use @baseline opt tools to build ocaml_tool targets
    compiler = "@baseline//bin:ocamlc.opt"
    ocamlrun = "@baseline//bin:ocamlrun"
    runtime  = "@baseline//lib:libcamlrun.a"

    protocol = settings["//config/build/protocol"]

    # if protocol == "preboot":
    #     return {}

    # config_executor = "vm"
    # config_emitter  = "vm"

    # if protocol == "unspecified":
    #     protocol = "boot"
    #     compiler = "//boot:ocamlc.byte"
    #     runtime  = "//runtime:camlrun"
    #     cvt_emit = settings["//toolchain:cvt_emit"]

    # elif protocol == "dev":
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:libasmrun.a"
    # else:
    #     compiler = "//bin:ocamlc.byte"
    #     # lexer    = "//lex:ocamllex.byte"
    #     runtime  = "//runtime:asmrun"
    #     cvt_emit = "//asmcomp:cvt_emit.byte"

    return {
        # "//config/target/executor": config_executor,
        # "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:ocamlrun"  : ocamlrun,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocaml_tool_vm_in_transition = transition(
    implementation = _ocaml_tool_vm_in_transition_impl,
    inputs = [
        "//config/build/protocol",
    ],
    outputs = [
        # "//config/target/executor",
        # "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocaml_tool_sys_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocaml_tool_sys_in_transition")

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "sys"

    if protocol == "unspecified":
        protocol = "boot"
        compiler = "//boot:ocamlopt.opt"
        runtime  = "//runtime:asmrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "boot":
        compiler = "//boot:ocamlopt.opt"
        runtime  = "//runtime:asmrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    # elif protocol == "dev":
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:libasmrun.a"

    else:
        fail("Protocol not yet supported: %s" % protocol)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocaml_tool_sys_in_transition = transition(
    implementation = _ocaml_tool_sys_in_transition_impl,
    inputs = [
        "//config/build/protocol",
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

################################################################
################################################################
def _ocamlc_byte_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocamlc_byte_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    if protocol == "preboot":
        return {}

    config_executor = "vm"
    config_emitter  = "vm"

    if protocol == "boot":  ## default, from the cmd line
        # goal: build _boot/ocamlc.byte from boot/ocamlc.boot
        config_executor = "boot"
        config_emitter  = "boot"
        # compiler = "//boot:ocamlc.boot"
        fail()
        runtime  = "//runtime:camlrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "baseline":
        # goal: build _boot/ocamlc.byte from boot/ocamlc.boot
        # then _baseline/ocamlc.byte from _boot/ocamlc.byte
        protocol = "boot"
        # config_executor = "vm"
        # config_emitter  = "vm"
        compiler = "//boot:ocamlc.byte"
        runtime  = "//runtime:camlrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "test":
        compiler = "@baseline//bin:ocamlc.byte"
        runtime  = "@baseline//lib:libasmrun.a"
        cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     ## use coldstart ocamlc.opt to build ocamlc.byte
    #     config_executor = "sys"
    #     config_emitter  = "vm"
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     runtime  = "@baseline//lib:libasmrun.a"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    if debug:
        print("setting //config/build/protocol:  %s" % protocol)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter:  %s" % config_emitter)
        print("setting //toolchain:compiler:     %s" % compiler)
        print("setting//toolchain:runtime:       %s" % runtime)
        # print("setting//toolchain:cvt_emit:      %s" % cvt_emit)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlc_byte_in_transition = transition(
    implementation = _ocamlc_byte_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocamlopt_byte_in_transition_impl(settings, attr):
    debug = False
    if debug:
        print("ocamlopt_byte_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    config_executor = "vm"
    config_emitter  = "sys"

    if protocol == "boot":
        config_executor = "boot"
        config_emitter  = "boot"
        # compiler = "//boot:ocamlc.boot"
        fail()
        runtime  = "//runtime:camlrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "baseline":
        config_executor = "vm"
        config_emitter  = "sys"
        compiler = "//bin/baseline:ocamlc.byte"
        runtime  = "//runtime:camlrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    # elif protocol == "dev":
    #     # use ocamlc.opt to build ocamlopt.byte
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     runtime  = "@baseline//lib:libasmrun.a"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlopt_byte_in_transition = transition(
    implementation = _ocamlopt_byte_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocamlopt_opt_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocamlopt_opt_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "sys"

    if protocol == "boot":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//boot:ocamlopt.byte"
        runtime  = "//runtime:asmrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "baseline":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin/baseline:ocamlopt.byte"
        runtime  = "//runtime:asmrun"      ##FIXME ???
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:libasmrun.a"  ##FIXME ???
        cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     print("sys/sys DEVTXN")
    #     # we're targeting ocamlopt.opt, so we use same
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:libasmrun.a"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlopt_opt_in_transition = transition(
    implementation = _ocamlopt_opt_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocamlc_opt_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocamlc_opt_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "vm"

    if protocol == "boot":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlopt.byte"
        runtime  = "//runtime:camlrun"

    elif protocol == "baseline":
        config_executor = "sys"
        config_emitter  = "vm"
        compiler = "//bin/baseline:ocamlopt.opt"
        runtime  = "//runtime:camlrun"

    # elif protocol == "dev":
    #     # we're targeting ocamlc.opt, so we use ocamlopt.opt
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:libasmrun.a"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocamlc_opt_in_transition = transition(
    implementation = _ocamlc_opt_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)
