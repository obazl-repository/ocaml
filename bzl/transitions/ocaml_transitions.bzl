##########################################################
def _ocamlc_byte_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocamlc_byte_in_transition")

    config_executor = "vm"
    config_emitter  = "vm"

    if settings["//config:test"] == True:
        compiler = "@baseline//bin:ocamlc.byte"
        # lexer    = "@baseline//bin:ocamllex.byte"
        cvt_emit = "@baseline//bin:cvt_emit.byte"
        runtime  = "@baseline//lib:libasmrun.a"

    elif settings["//config:dev"] == True:
        # if settings["//config:test"] == True:
        #     compiler = "@baseline//bin:ocamlc.opt"
        #     lexer    = "@baseline//bin:ocamllex.opt"
        #     cvt_emit = "@baseline//bin:cvt_emit.opt"
        #     runtime  = "@baseline//lib:libasmrun.a"
        # else:
        ## use coldstart ocamlc.opt to build ocamlc.byte
        config_executor = "sys"
        config_emitter  = "vm"
        compiler = "@baseline//bin:ocamlc.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        # no change
        config_executor = settings["//config/target/executor"]
        config_emitter  = settings["//config/target/emitter"]
        compiler = settings["//toolchain:compiler"]
        runtime  = settings["//toolchain:runtime"]
        cvt_emit = settings["//toolchain:cvt_emit"]

    if debug:
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter:  %s" % config_emitter)
        print("setting //toolchain:compiler:     %s" % compiler)
        print("setting//toolchain:runtime:       %s" % runtime)
        print("setting//toolchain:cvt_emit:      %s" % cvt_emit)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlc_byte_in_transition = transition(
    implementation = _ocamlc_byte_in_transition_impl,
    inputs = [
        "//config:dev",
        "//config:test",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ]
)

##########################################################
def _ocamlopt_byte_in_transition_impl(settings, attr):
    debug = True
    if debug:
        print("ocamlopt_byte_in_transition")

    ## build host: sys>vm, target: vm>sys
    config_executor = "sys"
    config_emitter  = "vm"

    if settings["//config:dev"] == True:
        # use ocamlc.opt to build ocamlopt.byte
        compiler = "@baseline//bin:ocamlc.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        runtime  = "@baseline//lib:libasmrun.a"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
    else:
        config_executor = settings["//config/target/executor"]
        config_emitter  = settings["//config/target/emitter"]
        compiler = settings["//toolchain:compiler"]
        # lexer    = settings["//toolchain:lexer"]
        runtime  = settings["//toolchain:runtime"]
        cvt_emit = settings["//toolchain:cvt_emit"]

        # compiler = "//bin:ocamlcc"
        # lexer    = "//lex:ocamllex"
        # runtime  = "//runtime:asmrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]


    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlopt_byte_in_transition = transition(
    implementation = _ocamlopt_byte_in_transition_impl,
    inputs = [
        "//config:dev",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
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
def _ocamlopt_opt_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocamlopt_opt_in_transition")

    config_executor = "sys"
    config_emitter  = "sys"

    if settings["//config:dev"] == True:
        print("sys/sys DEVTXN")
        # we're targeting ocamlopt.opt, so we use same
        compiler = "@baseline//bin:ocamlopt.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        print("NODEVTXN")
        config_executor = settings["//config/target/executor"]
        config_emitter  = settings["//config/target/emitter"]
        compiler = settings["//toolchain:compiler"]
        # lexer    = settings["//toolchain:lexer"]
        runtime  = settings["//toolchain:runtime"]
        cvt_emit = settings["//toolchain:cvt_emit"]

        # compiler = "//bin:ocamlopt.opt"
        # lexer    = "//lex:ocamllex.opt"
        # runtime  = "//runtime:asmrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]


    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlopt_opt_in_transition = transition(
    implementation = _ocamlopt_opt_in_transition_impl,
    inputs = [
        "//config:dev",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
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
def _ocamlc_opt_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocamlc_opt_in_transition")

    config_executor = "sys"
    config_emitter  = "sys"

    if settings["//config:dev"] == True:
        # we're targeting ocamlc.opt, so we use ocamlopt.opt
        compiler = "@baseline//bin:ocamlopt.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        config_executor = settings["//config/target/executor"]
        config_emitter  = settings["//config/target/emitter"]
        compiler = settings["//toolchain:compiler"]
        # lexer    = settings["//toolchain:lexer"]
        runtime  = settings["//toolchain:runtime"]
        cvt_emit = settings["//toolchain:cvt_emit"]

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlc_opt_in_transition = transition(
    implementation = _ocamlc_opt_in_transition_impl,
    inputs = [
        "//config:dev",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
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

