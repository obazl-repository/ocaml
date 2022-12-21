##########################################################
def _ocamlc_byte_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocamlc_byte_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    config_executor = "vm"
    config_emitter  = "vm"

    if protocol == "unspecified":
        protocol = "boot"
        compiler = "//boot:ocamlc.byte"
        runtime  = "//runtime:camlrun"
        cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "boot":
        compiler = "//boot:ocamlc.boot"
        runtime  = "//runtime:camlrun"
        cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "test":
        compiler = "@baseline//bin:ocamlc.byte"
        runtime  = "@baseline//lib:libasmrun.a"
        cvt_emit = "@baseline//bin:cvt_emit.byte"

    elif protocol == "dev":
        ## use coldstart ocamlc.opt to build ocamlc.byte
        config_executor = "sys"
        config_emitter  = "vm"
        compiler = "@baseline//bin:ocamlc.opt"
        runtime  = "@baseline//lib:libasmrun.a"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
    else:
        fail("Protocol not yet supported: %s" % protocol)

    if debug:
        print("setting //config/build/protocol:  %s" % protocol)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter:  %s" % config_emitter)
        print("setting //toolchain:compiler:     %s" % compiler)
        print("setting//toolchain:runtime:       %s" % runtime)
        print("setting//toolchain:cvt_emit:      %s" % cvt_emit)

    return {
        "//config/build/protocol" : protocol,
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
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ],
    outputs = [
        "//config/build/protocol",
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
        print("ocamlopt_byte_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    config_executor = "vm"
    config_emitter  = "sys"

    if protocol == "unspecified":
        protocol = "boot"
        config_executor = "vm"
        config_emitter  = "sys"
        compiler = "//boot:ocamlc.byte"
        runtime  = "//runtime:camlrun"
        cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "boot":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//boot:ocamlopt.byte"
        runtime  = "//runtime:camlrun"
        cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "dev":
        # use ocamlc.opt to build ocamlopt.byte
        compiler = "@baseline//bin:ocamlc.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        runtime  = "@baseline//lib:libasmrun.a"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
    else:
        fail("Protocol not yet supported: %s" % protocol)

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
    }

################################################################
ocamlopt_byte_in_transition = transition(
    implementation = _ocamlopt_byte_in_transition_impl,
    inputs = [
        "//config/build/protocol",
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
    if debug: print("ocamlopt_opt_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "sys"

    if protocol == "unspecified":
        protocol = "boot"
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//boot:ocamlopt.byte"
        runtime  = "//runtime:asmrun"
        cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "boot":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//boot:ocamlopt.byte"
        runtime  = "//runtime:asmrun"
        cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "dev":
        print("sys/sys DEVTXN")
        # we're targeting ocamlopt.opt, so we use same
        compiler = "@baseline//bin:ocamlopt.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        fail("Protocol not yet supported: %s" % protocol)

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
        "//config/build/protocol",
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
    if debug: print("ocamlc_opt_in_transition: %s" % attr.name)

    config_executor = "sys"
    config_emitter  = "sys"

    if settings["//config/build/protocol"] == "dev":
        # we're targeting ocamlc.opt, so we use ocamlopt.opt
        compiler = "@baseline//bin:ocamlopt.opt"
        # lexer    = "@baseline//bin:ocamllex.opt"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
        runtime  = "@baseline//lib:libasmrun.a"
    else:
        config_executor = "sys"
        config_emitter  = "vm"

        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"

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
        "//config/build/protocol",
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

