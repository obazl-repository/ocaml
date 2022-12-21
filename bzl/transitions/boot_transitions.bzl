##############################################
def tc_boot_in_transition_impl(settings, attr, debug):
    debug = True

    executor = settings["//config/target/executor"]
    emitter  = settings["//config/target/emitter"]
    compiler = settings["//toolchain:compiler"]
    # lexer    = settings["//toolchain:lexer"]
    runtime  = settings["//toolchain:runtime"]

    if debug:
        print("tc_boot_in_transition_impl")
        print("protocol: %s" % settings["//config/build/protocol"])
        print("//config/target:executor: %s" % executor)
        print("//config/target:emitter:  %s" % emitter)
        print("//toolchain:compiler:     %s" % compiler)
        # print("//toolchain:lexer         %s" % lexer)
        print("//toolchain:runtime       %s" % runtime)

    if settings["//config/build/protocol"] == "dev":
        compiler = "@baseline//bin:ocamlc.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        runtime  = "@baseline//lib:libasmrun.a"
        executor = settings["//config/target/executor"]
        emitter  = settings["//config/target/emitter"]
    else:
        compiler = "//boot:ocamlc.boot"
        # lexer    = "//boot:ocamllex.boot"
        runtime  = "//runtime:asmrun"

        executor = "boot"
        emitter  = "boot"

    if debug:
        print("setting //config/target/executor: %s" % executor)
        print("setting //config/target/emitter:  %s" % emitter)
        print("setting //toolchain:compiler:     %s" % compiler)
        # print("setting //toolchain:lexer:        %s" % lexer)
        print("setting//toolchain:runtime:       %s" % runtime)

    return {
        "//config/target/executor": executor,
        "//config/target/emitter" : emitter,

        "//toolchain:compiler" : compiler,
        # "//toolchain:lexer"    : lexer,
        "//toolchain:runtime"  : runtime
    }

#####################################################
def _tc_boot_in_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_boot_in_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    return tc_boot_in_transition_impl(settings, attr, debug)

#######################
tc_boot_in_transition = transition(
    implementation = _tc_boot_in_transition_impl,

    inputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",

        "//config/build/protocol",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
    ]
)
