load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load(":transitions.bzl",
     # "tc_boot_in_transition_impl",
     "tc_compiler_out_transition_impl",
     "tc_runtime_out_transition_impl",
     "tc_mustache_transition_impl",
     # "reset_config_transition_impl"
     )

#####################################################
def _tc_compiler_out_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_compiler_out_transition")
        print("tc name: %s" % attr.name)
        print("protocol: %s" % settings["//config/build/protocol"])

    if settings["//config/build/protocol"] == "test":
        print("identity txn ")
        return {}

    if settings["//config/build/protocol"] == "boot":
        print("boot identity txn ")
        return {}

    return tc_compiler_out_transition_impl(settings, attr, debug)

#######################
tc_compiler_out_transition = transition(
    implementation = _tc_compiler_out_transition_impl,
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

#####################################################
def _tc_runtime_out_transition_impl(settings, attr):

    debug = True

    if debug:
        print("ENTRY: tc_runtime_out_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    return tc_runtime_out_transition_impl(settings, attr, debug)

#######################
tc_runtime_out_transition = transition(
    implementation = _tc_runtime_out_transition_impl,
    inputs = [
        "//config/build/protocol",

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

