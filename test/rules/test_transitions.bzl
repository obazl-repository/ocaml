load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

################################################################
def _vv_test_in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("vv_test_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    protocol = "test"

    config_executor = "vm"
    config_emitter  = "vm"

    if settings["//config/ocaml/compiler"]== "baseline":
        compiler = "@baseline//bin:ocamlc.byte"
        ocamlrun = "@baseline//bin:ocamlrun"
        runtime  = "@baseline//lib:libcamlrun.a"
    else:
        compiler = "//test:ocamlc.byte"
        ocamlrun = "//runtime:ocamlrun"
        runtime  = "//runtime:camlrun"


    # mustach  = "@baseline//bin:mustach"
    # cvt_emit = "@baseline//bin:cvt_emit.byte"

    if debug:
        print("setting executor:  %s" % config_executor)
        print("setting emitter:   %s" % config_emitter)
        print("setting compiler:  %s" % compiler)
        # print("setting lexer:     %s" % lexer)
        print("setting runtime:   %s" % runtime)
        # print("setting cvt_emit:  %s" % cvt_emit)

    return {
        "//config/build/protocol" : "test",
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:ocamlrun"    : ocamlrun,
        "//toolchain:runtime"     : runtime,
        # "//toolchain:cvt_emit"    : cvt_emit,
        # "//toolchain:mustach"     : mustach
    }

#########################################
vv_test_in_transition = transition(
    implementation = _vv_test_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/ocaml/compiler"
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit",
        # "//toolchain:mustach"
    ]
)

################################################################
def _vs_test_in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("vs_test_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    protocol = "test"

    config_executor = "vm"
    config_emitter  = "sys"

    if settings["//config/ocaml/compiler"]== "baseline":
        compiler = "@baseline//bin:ocamlopt.byte"
        # runtime  = "//runtime:asmrun"
        runtime  = "@baseline//lib:libasmrun.a"
        ocamlrun = "@baseline//bin:ocamlrun"
    else:
        compiler = "//test:ocamlopt.byte"
        runtime  = "//runtime:asmrun"
        ocamlrun = "//runtime:ocamlrun"

    if debug:
        print("setting executor:  %s" % config_executor)
        print("setting emitter:   %s" % config_emitter)
        print("setting compiler:  %s" % compiler)
        print("setting runtime:   %s" % runtime)
        # print("setting cvt_emit:  %s" % cvt_emit)

    return {
        "//config/build/protocol" : "test",
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:ocamlrun"    : ocamlrun,
        "//toolchain:runtime"     : runtime,
        # "//toolchain:cvt_emit"    : cvt_emit,
        # "//toolchain:mustach"     : mustach
    }

#########################################
vs_test_in_transition = transition(
    implementation = _vs_test_in_transition_impl,
    inputs = [
        "//config/ocaml/compiler",
        "//config/build/protocol"
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit",
        # "//toolchain:mustach"
    ]
)

################################################################
def _ss_test_in_transition_impl(settings, attr):

    debug = False

    if debug:
        print("ss_test_in_transition: %s" % attr.name)

    config_executor = "sys"
    config_emitter  = "sys"

    protocol = settings["//config/build/protocol"]

    if protocol == "test":
        return {}

    protocol = "test"

    config_executor = "sys"
    config_emitter  = "sys"

    compiler = "//test:ocamlopt.opt"
    ocamlrun = "@baseline//bin:ocamlrun"
    # ocamlrun = "//runtime:ocamlrun"
    runtime  = "@baseline//lib:libasmrun.a"
    # mustach  = "@baseline//bin:mustach"
    # cvt_emit = "@baseline//bin:cvt_emit.byte"
    # else:
    #     fail("Protocol not yet supported for test: %s" % protocol)

    if debug:
        print("setting executor:  %s" % config_executor)
        print("setting emitter:   %s" % config_emitter)
        print("setting compiler:  %s" % compiler)
        print("setting runtime:   %s" % runtime)
        # print("setting cvt_emit:  %s" % cvt_emit)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:runtime"     : runtime,
        # "//toolchain:ocamlrun"    : ocamlrun,
        # "//toolchain:mustach"     : mustach
    }

#######################
ss_test_in_transition = transition(
    implementation = _ss_test_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        # "//config/target/executor",
        # "//config/target/emitter",
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:ocamlrun",
        # "//toolchain:cvt_emit",
        # "//toolchain:mustach"
    ]
)

################################################################
def _sv_test_in_transition_impl(settings, attr):

    debug = False

    if debug:
        print("sv_test_in_transition: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    if protocol == "test":
        return {}

    protocol = "test"

    config_executor = "sys"
    config_emitter  = "vm"

    compiler = "//test:ocamlc.opt"
    # ocamlrun = "//runtime:ocamlrun"
    runtime  = "@baseline//lib:libcamlrun.a"
    # mustach  = "@baseline//bin:mustach"
    # cvt_emit = "@baseline//bin:cvt_emit.byte"
    # else:
    #     fail("Protocol not yet supported for test: %s" % protocol)

    if debug:
        print("setting executor:  %s" % config_executor)
        print("setting emitter:   %s" % config_emitter)
        print("setting compiler:  %s" % compiler)
        print("setting runtime:   %s" % runtime)
        # print("setting cvt_emit:  %s" % cvt_emit)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:runtime"     : runtime,
        # "//toolchain:ocamlrun"    : ocamlrun,
        # "//toolchain:mustach"     : mustach
    }

#######################
sv_test_in_transition = transition(
    implementation = _sv_test_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        # "//config/target/executor",
        # "//config/target/emitter",
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:ocamlrun",
        # "//toolchain:cvt_emit",
        # "//toolchain:mustach"
    ]
)
