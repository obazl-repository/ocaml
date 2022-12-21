load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

################################################################
def _vv_test_in_transition_impl(settings, attr):
    debug = True

    if debug:
        print("vv_test_in_transition: %s" % attr.name)

    config_executor = "vm"
    config_emitter  = "vm"

    protocol = settings["//config/build/protocol"]

    if protocol == "unspecified":
        protocol = "test"
        config_executor = "vm"
        config_emitter  = "vm"
        ## we only want to rebuild the compiler, not the bld tools
        compiler = "//bin:ocamlc.byte"
        ocamlrun = "//runtime:ocamlrun"
        runtime  = "@baseline//lib:libcamlrun.a"
        mustach  = "@baseline//bin:mustach"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
    else:
        fail("Protocol not yet supported for test: %s" % protocol)

    if debug:
        print("setting executor:  %s" % config_executor)
        print("setting emitter:   %s" % config_emitter)
        print("setting compiler:  %s" % compiler)
        # print("setting lexer:     %s" % lexer)
        print("setting runtime:   %s" % runtime)
        print("setting cvt_emit:  %s" % cvt_emit)

    return {
        "//config/build/protocol" : "test",
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:ocamlrun"    : ocamlrun,
        "//toolchain:runtime"     : runtime,
        "//toolchain:cvt_emit"    : cvt_emit,
        "//toolchain:mustach"     : mustach
    }

#########################################
vv_test_in_transition = transition(
    implementation = _vv_test_in_transition_impl,
    inputs = ["//config/build/protocol"],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
        "//toolchain:cvt_emit",
        "//toolchain:mustach"
    ]
)

################################################################
def _ss_test_in_transition_impl(settings, attr):

    debug = True

    if debug:
        print("ss_test_in_transition: %s" % attr.name)

    config_executor = "sys"
    config_emitter  = "sys"

    protocol = settings["//config/build/protocol"]

    if protocol == "unspecified":
        protocol = "test"
        config_executor = "sys"
        config_emitter  = "sys"
        ## we only want to rebuild the compiler, not the bld tools
        compiler = "//bin:ocamlopt.opt"
        ocamlrun = "//runtime:ocamlrun"
        runtime  = "@baseline//lib:libasmrun.a"
        mustach  = "@baseline//bin:mustach"
        cvt_emit = "@baseline//bin:cvt_emit.opt"
    else:
        fail("Protocol not yet supported for test: %s" % protocol)

    if debug:
        print("setting executor:  %s" % config_executor)
        print("setting emitter:   %s" % config_emitter)
        print("setting compiler:  %s" % compiler)
        # print("setting lexer:     %s" % lexer)
        print("setting runtime:   %s" % runtime)
        print("setting cvt_emit:  %s" % cvt_emit)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:ocamlrun"    : ocamlrun,
        "//toolchain:runtime"     : runtime,
        "//toolchain:cvt_emit"    : cvt_emit,
        "//toolchain:mustach"     : mustach
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
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
        "//toolchain:cvt_emit",
        "//toolchain:mustach"
    ]
)
