load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load(":transitions.bzl",
     "tc_target_transitions",
     # "tc_runtime_out_transition_impl",
     "tc_mustache_transition_impl",
     )

##############################################
def _tc_runtime_out_transition_impl(settings, attr, debug):
    debug = True
    if debug: print("tc_runtime_out_transition")

    protocol = settings["//config/build/protocol"]

    fail("TCR")

    if protocol == "boot":
        return {}

    config_executor, config_emitter = tc_target_transitions(settings, attr, debug)

    if debug:
        print("//toolchain:runtime: %s" % settings["//toolchain:runtime"])

    if config_executor == "boot":
        print("rttxn CC TRANSITION")
        return {}
    elif (config_executor == "boot"): #and config_emitter == "boot"):
        print("rttxn BOOT TRANSITION")
        rt_target  = "camlrun"
    elif (config_executor == "baseline"):
        print("rttxn BASELINE TRANSITION")
        rt_target  = "camlrun"
    elif (config_executor == "vm" and config_emitter == "vm"):
        print("rttxn VM-VM TRANSITION")
        rt_target  = "camlrun"

    elif (config_executor == "vm" and config_emitter == "sys"):
        print("rttxn VM-SYS TRANSITION")
        rt_target  = "asmrun"
    elif (config_executor == "sys" and config_emitter == "sys"):
        print("rttxn SYS-SYS TRANSITION")
        rt_target  = "asmrun"
    elif (config_executor == "sys" and config_emitter == "vm"):
        print("rttxn SYS-VM TRANSITION")
        rt_target  = "camlrun"

    if protocol == "dev":
        runtime = "@dev//lib:asmrun"
        # runtime = "@dev//lib:lib" + rt_target + ".a"
    else:
        runtime = "//runtime:" + rt_target

    if debug:
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        print("setting //toolchain:runtime %s" % runtime)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : settings["//toolchain:compiler"],
        # "//toolchain:lexer"       : settings["//toolchain:lexer"],
        "//toolchain:runtime"     : runtime
    }

#####################################################
# def _tc_runtime_out_transition_impl(settings, attr):

#     debug = True

#     if debug:
#         print("ENTRY: tc_runtime_out_transition")
#         print("tc name: %s" % attr.name)
#         # print("attrs: %s" % attr)

#     return tc_runtime_out_transition_impl(settings, attr, debug)

#######################
tc_runtime_out_transition = transition(
    implementation = _tc_runtime_out_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        "//toolchain:ocamlrun",
        # "//toolchain:lexer",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        # "//toolchain:cvt_emit",
        "//toolchain:runtime",
    ]
)

#####################################################
def _tc_mustache_out_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_mustache_out_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    return tc_mustache_transition_impl(settings, attr, debug)

#######################
tc_mustache_out_transition = transition(
    implementation = _tc_mustache_out_transition_impl,

    inputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
    ]
)

