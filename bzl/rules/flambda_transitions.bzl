################################################################
## flambda transition functions
################################################################
def _ocamloptx_byte_in_transition_impl(settings, attr):

    ## same as _ocamlopt_byte, except for setting
    ##      "//config/ocaml/flambda:enabled": True,

    debug = False
    if debug: print("ocamloptx_byte_in_transition: %s" % attr.name)

    ## set //config/ocaml/flambda:enabled

    protocol = settings["//config/build/protocol"]

    config_executor = "vm"
    config_emitter  = "sys"

    if protocol == "std":
        # config_executor = "sys"
        # config_emitter  = "sys"
        compiler = "//boot:ocamlc.boot"
        runtime  = "//runtime:camlrun"
        # compiler = "//bin:ocamlopt.byte"
        # runtime  = "//runtime:asmrun"

    elif protocol == "boot":  ## coldstart
        # bootstrap:
        # -> boot:ocamlc.boot -> bin:ocamlc.byte
        # -> bin:ocamlc.byte -> bin:ocamlopt.byte
        # -> bin:ocamlopt.opt -> bin:ocamlopt.opt
        # -> bin:ocamlopt.opt -> bin:ocamlc.opt
        protocol = "std"
        # config_executor = "sys"
        # config_emitter  = "vm"
        compiler = "//bin:ocamlc.byte"
        runtime  = "//runtime:camlrun"

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"  ##FIXME ???
        # cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     # we're targeting ocamlc.opt, so we use ocamlopt.opt
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/ocaml/flambda:enabled": True,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocamloptx_byte_in_transition = transition(
    implementation = _ocamloptx_byte_in_transition_impl,
    inputs = [
        "//config/ocaml/flambda:enabled",
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/ocaml/flambda:enabled",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)

################################################################
def _ocamloptx_opt_in_transition_impl(settings, attr):

    debug = False
    if debug: print("ocamloptx_opt_in_transition: %s" % attr.name)

    ## set //config/ocaml/flambda:enabled

    protocol = settings["//config/build/protocol"]

    config_executor = "vm"
    config_emitter  = "sys"

    # use ocamlopt.opt to build ocamloptx.opt
    if protocol == "std":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"

    elif protocol == "boot":  ## coldstart
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"
        # protocol = "std"
        # # config_executor = "sys"
        # # config_emitter  = "vm"
        # compiler = "//bin:ocamlc.byte"
        # runtime  = "//runtime:camlrun"

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"  ##FIXME ???
        # cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     # we're targeting ocamlc.opt, so we use ocamlopt.opt
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/ocaml/flambda:enabled": True,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocamloptx_opt_in_transition = transition(
    implementation = _ocamloptx_opt_in_transition_impl,
    inputs = [
        "//config/ocaml/flambda:enabled",
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/ocaml/flambda:enabled",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)

##########################################################
def _ocamlc_optx_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocamlc_optx_in_transition: %s" % attr.name)

    ## set //config/ocaml/flambda:enabled

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "vm"

    if protocol == "std":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlopt.byte"
        runtime  = "//runtime:asmrun"

    elif protocol == "boot":
        # bootstrap:
        # -> boot:ocamlc.boot -> bin:ocamlc.byte
        # -> bin:ocamlc.byte -> bin:ocamlopt.byte
        # -> bin:ocamlopt.opt -> bin:ocamlopt.opt
        # -> bin:ocamlopt.opt -> bin:ocamlc.opt
        protocol = "std"
        # config_executor = "sys"
        # config_emitter  = "vm"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"  ##FIXME ???
        # cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     # we're targeting ocamlc.opt, so we use ocamlopt.opt
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/ocaml/flambda:enabled": True,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocamlc_optx_in_transition = transition(
    implementation = _ocamlc_optx_in_transition_impl,
    inputs = [
        "//config/ocaml/flambda:enabled",
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/ocaml/flambda:enabled",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)

##########################################################
def _ocamlopt_optx_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocamlopt_optx_in_transition: %s" % attr.name)

    ## set //config/ocaml/flambda:enabled

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "sys"

    if protocol == "std":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamloptx.optx"
        runtime  = "//runtime:asmrun"

    elif protocol == "boot":
        # bootstrap:
        # -> boot:ocamlc.boot -> bin:ocamlc.byte
        # -> bin:ocamlc.byte -> bin:ocamlopt.byte
        # -> bin:ocamlopt.opt -> bin:ocamlopt.opt
        # -> bin:ocamlopt.opt -> bin:ocamlc.opt
        protocol = "std"
        # config_executor = "sys"
        # config_emitter  = "vm"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"  ##FIXME ???
        # cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     # we're targeting ocamlc.opt, so we use ocamlopt.opt
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/ocaml/flambda:enabled": False,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocamlopt_optx_in_transition = transition(
    implementation = _ocamlopt_optx_in_transition_impl,
    inputs = [
        "//config/ocaml/flambda:enabled",
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/ocaml/flambda:enabled",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)

##########################################################
def _ocamloptx_optx_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocamloptx_optx_in_transition: %s" % attr.name)

    ## set //config/ocaml/flambda:enabled

    protocol = settings["//config/build/protocol"]

    config_executor = "sys"
    config_emitter  = "vm"

    if protocol == "std":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamloptx.opt"
        runtime  = "//runtime:asmrun"

    # if protocol == "std":
    #     config_executor = "sys"
    #     config_emitter  = "sys"
    #     compiler = "//bin:ocamlopt.byte"
    #     runtime  = "//runtime:asmrun"

    elif protocol == "boot":
        # bootstrap:
        # -> boot:ocamlc.boot -> bin:ocamlc.byte
        # -> bin:ocamlc.byte -> bin:ocamlopt.byte
        # -> bin:ocamlopt.opt -> bin:ocamlopt.opt
        # -> bin:ocamlopt.opt -> bin:ocamlc.opt
        protocol = "std"
        # config_executor = "sys"
        # config_emitter  = "vm"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"  ##FIXME ???
        # cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     # we're targeting ocamlc.opt, so we use ocamlopt.opt
    #     compiler = "@baseline//bin:ocamlopt.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    return {
        "//config/ocaml/flambda:enabled": True,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocamloptx_optx_in_transition = transition(
    implementation = _ocamloptx_optx_in_transition_impl,
    inputs = [
        "//config/ocaml/flambda:enabled",
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/ocaml/flambda:enabled",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)
