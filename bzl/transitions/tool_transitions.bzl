##########################################################
def _ocaml_tool_vm_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocaml_tool_vm_in_transition")

    config_executor = "vm"
    config_emitter  = "vm"

    if settings["//config/build/protocol"] == "dev":
        compiler = "@baseline//bin:ocamlc.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        compiler = "//bin:ocamlc.byte"
        # lexer    = "//lex:ocamllex.byte"
        runtime  = "//runtime:asmrun"
        cvt_emit = "//asmcomp:cvt_emit.opt"

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocaml_tool_vm_in_transition = transition(
    implementation = _ocaml_tool_vm_in_transition_impl,
    inputs = [
        "//config/build/protocol",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocaml_tool_sys_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocaml_tool_sys_in_transition")

    config_executor = "sys"
    config_emitter  = "sys"

    if settings["//config/build/protocol"] == "dev":
        compiler = "@baseline//bin:ocamlopt.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        compiler = "//bin:ocamlc.byte"
        # lexer    = "//lex:ocamllex.opt"
        runtime  = "//runtime:asmrun"
        cvt_emit = "//toolchain:cvt_emit"

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocaml_tool_sys_in_transition = transition(
    implementation = _ocaml_tool_sys_in_transition_impl,
    inputs = [
        "//config/build/protocol",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ]
)

################################################################
##########################################################
def _build_tool_vm_in_transition_impl(settings, attr):
    debug = True
    if debug: print("build_tool_vm_in_transition")

    config_executor = "vm"
    config_emitter  = "vm"

    if settings["//config/build/protocol"] == "dev":
        compiler = "@baseline//bin:ocamlc.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        compiler = "//bin:ocamlc.byte"
        # lexer    = "//lex:ocamllex.byte"
        runtime  = "//runtime:asmrun"
        cvt_emit = "//asmcomp:cvt_emit"
        ## settings["//toolchain:cvt_emit"]

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
build_tool_vm_in_transition = transition(
    implementation = _build_tool_vm_in_transition_impl,
    inputs = ["//config/build/protocol"],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ]
)

##########################################################
def _build_tool_sys_in_transition_impl(settings, attr):
    debug = True
    if debug: print("build_tool_sys_in_transition")

    config_executor = "sys"
    config_emitter  = "sys"

    if settings["//config/build/protocol"] == "dev":
        compiler = "@baseline//bin:ocamlopt.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        compiler = "//bin:ocamlopt.opt"
        # lexer    = "//lex:ocamllex.opt"
        runtime  = "//runtime:asmrun"
        cvt_emit = "//asmcomp:cvt_emit"
        ## settings["//toolchain:cvt_emit"]

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime
    }

################################################################
build_tool_sys_in_transition = transition(
    implementation = _build_tool_sys_in_transition_impl,
    inputs = ["//config/build/protocol"],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
    ]
)

#####################################################
# def _ocaml_tool_in_transition_impl(settings, attr, debug):

#     print("ocaml_tool_in_transition")
#     debug = True

#     ## we use the CLI string flags in //config/...
#     ## to set string settings in //toolchain/...
#     config_executor = settings["//config/target/executor"]
#     config_emitter  = settings["//config/target/emitter"]
#     # target_runtime  = settings["//toolchain:runtime"]

#     compiler = settings["//toolchain:compiler"]
#     lexer = settings["//toolchain:lexer"]

#     # build_host  = settings["//command_line_option:host_platform"]
#     # extra_execution_platforms = settings["//command_line_option:extra_execution_platforms"]

#     # target_host = settings["//command_line_option:platforms"]

#     # stage = int(settings["//config/stage"])

#     if debug:
#         # print("//config/stage: %s" % stage)
#         print("//config/target/executor: %s" % settings[
#             "//config/target/executor"])
#         print("//config/target/emitter:  %s" % settings[
#             "//config/target/emitter"])

#         print("//toolchain:compiler:  %s" % settings["//toolchain:compiler"])
#         print("//toolchain:lexer:  %s" % settings["//toolchain:lexer"])
#         print("//toolchain:runtime:  %s" % settings["//toolchain:runtime"])

#         # print("//toolhchain:runtime:     %s" % target_runtime)
#         # print("attr.target_executor: %s" % attr.target_executor)
#         # print("//command_line_option:host_platform: %s" % build_host)
#         # print("//command_line_option:extra_execution_platforms: %s" % extra_execution_platforms)
#         # print("//command_line_option:platforms: %s" % target_host)


#     ## avoid rebuilding _boot/ocamlc.byte: ??

#     host_compilation_mode = "opt"
#     compilation_mode = "opt"
#     # runtime  = "//runtime:ocamlrun"

#     ## initial config: config settings passed on cli, toolchain
#     ## configs default to unspecified

#     if config_executor == "boot":

#         print("CC TRANSITION")
#         return {}

#     elif (config_executor == "boot"): #and config_emitter == "boot"):
#         print("BOOT TRANSITION")
#         compilation_mode = "opt"
#         config_executor = "baseline"
#         config_emitter  = "baseline"

#         # if (compiler == "//boot:ocamlc.boot" and
#         #     lexer    == "//boot:ocamllex.boot"):
#         #     compiler = "//boot:ocamlc.boot"
#         #     lexer    = "//boot:ocamllex.boot"
#         #     runtime  = "//runtime:camlrun"
#         #     # return{}
#         # else:
#         compiler = "//boot:ocamlc.boot"
#         lexer    = "//boot:ocamllex.boot"
#         runtime  = "//runtime:camlrun"

#     elif (config_executor == "baseline"):
#         print("BASELINE transition")
#         config_executor = "boot"
#         config_emitter  = "boot"
#         compiler = "//boot:ocamlc.boot"
#         lexer    = "//boot:ocamllex.boot"
#         runtime  = "//runtime:camlrun"
#     #     fail("bad config_emitter: %s" % config_emitter)

#     elif (config_executor == "vm" and config_emitter == "vm"):
#         print("VM-VM TRANSITION")
#         config_executor = "baseline"
#         config_emitter  = "baseline"
#         ## these just prevent circular dep?
#         ## need to set before recurring, otherwise we get a dep cycle
#         compiler = "//bin:ocamlc.byte"
#         lexer    = "//lex:ocamllex.byte"
#         runtime  = "//runtime:asmrun"
#         # runtime  = "//runtime:camlrun"
#         # compiler = "//boot:ocamlc.boot"
#         # lexer    = "//boot:ocamllex.boot"

#     elif (config_executor == "vm" and config_emitter == "sys"):
#         print("VM-SYS transition")
#         config_executor = "vm"
#         config_emitter = "vm"
#         # target_executor = "boot"
#         # target_emitter = "boot"
#         # target_executor = "vm"
#         # target_emitter = "vm"
#         compiler = "//bin:ocamlc.byte"
#         lexer    = "//lex:ocamllex.byte"
#         runtime  = "//runtime:asmrun"

#     elif (config_executor == "sys" and config_emitter == "sys"):
#         print("SYS-SYS transition")
#         config_executor = "vm"
#         config_emitter  = "sys"
#         compiler = "//bin:ocamlc.byte"
#         lexer    = "//lex:ocamllex.byte"
#         runtime  = "//runtime:asmrun"

#     elif (config_executor == "sys" and config_emitter == "vm"):
#         print("SYS-VM transition")
#         config_executor = "sys"
#         config_emitter  = "sys"
#         compiler = "//bin:ocamlc.byte"
#         lexer    = "//lex:ocamllex.byte"
#         runtime  = "//runtime:asmrun"


#     else:
#         fail("xxxxxxxxxxxxxxxx %s" % config_executor)

#     if debug:
#         print("setting //config/target/executor: %s" % config_executor)
#         print("setting //config/target/emitter: %s" % config_emitter)
#         print("setting //toolchain:compiler %s" % compiler)
#         print("setting //toolchain:lexer %s" % lexer)

#     return {
#         "//config/target/executor": config_executor,
#         "//config/target/emitter" : config_emitter,
#     }

######################################
# ocaml_tool_in_transition = transition(
#     implementation = _ocaml_tool_in_transition_impl,
#     inputs = [
#         "//config/target/executor",
#         "//config/target/emitter",

#         "//toolchain:compiler",
#         "//toolchain:lexer",
#         "//toolchain:runtime",
#         "//toolchain:cvt_emit"
#     ],
#     outputs = [
#         "//config/target/executor",
#         "//config/target/emitter",

#         "//toolchain:compiler",
#         "//toolchain:lexer",
#         "//toolchain:runtime",
#         "//toolchain:cvt_emit"
#     ]
# )
