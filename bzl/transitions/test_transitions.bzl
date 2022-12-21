load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

################################################################
def _vv_test_in_transition_impl(settings, attr):
    debug = True

    if debug:
        print("vv_test_in_transition: %s" % attr.name)

    config_executor = "vm"
    config_emitter  = "vm"

    # if settings["//config/build/protocol"] == "dev":
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.opt"
    #     runtime  = "@baseline//lib:libasmrun.a"
    # else:

    ## we only want to rebuild the compiler, not the bld tools
    compiler = "//bin:ocamlc.byte"
    # lexer    = "@baseline//bin:ocamllex.opt"
    cvt_emit = "@baseline//bin:cvt_emit.opt"
    runtime  = "@baseline//lib:libasmrun.a"
    # lexer    = "//lex:ocamllex.byte"
    # runtime  = "//runtime:asmrun"
    # cvt_emit = "//asmcomp:cvt_emit"
        ## settings["//toolchain:cvt_emit"]

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
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        "//toolchain:cvt_emit"  : cvt_emit
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
        # "//toolchain:lexer",
        "//toolchain:runtime",
        "//toolchain:cvt_emit"
    ]
)

################################################################
def _ss_test_in_transition_impl(settings, attr):
    ## set //config/target/executor, emitter to vm
    return {
        "//config/target/executor": "sys",
        "//config/target/emitter" : "sys",
        "//toolchain:runtime"  : "@baseline//lib:libasmrun.a"
    }

#######################
ss_test_in_transition = transition(
    implementation = _ss_test_in_transition_impl,
    inputs = [
        # "//config/target/executor",
        # "//config/target/emitter",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:runtime",
    ]
)
