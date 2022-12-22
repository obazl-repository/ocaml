load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

#####################################################
def _dev_tc_compiler_out_transition_impl(settings, attr):

    ## base is @baseline/bin:ocamlc.byte
    ## in contrast to std ocaml tc, whose base is boot/ocamlc.boot

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True
    fail("DDDDEV")

    protocol = settings["//config/build/protocol"]

    if protocol == "boot":
        return {}

    if debug:
        print("ENTRY: dev_tc_compiler_out_transition")
        print("bld tgt: %s" % attr.name)
        print("tc name: %s" % attr.name)
        print("protocol: %s" % protocol)

    if settings["//config/build/protocol"] == "test":
        print("id txn ")
        return {}

    ## we use the CLI string flags in //config/...
    ## to set string settings in //toolchain/...

    config_executor = settings["//config/target/executor"]
    config_emitter  = settings["//config/target/emitter"]
    # target_runtime  = settings["//toolchain:runtime"]

    compiler = settings["//toolchain:compiler"]
    # lexer = settings["//toolchain:lexer"]
    runtime = settings["//toolchain:runtime"]
    # camlheaders = settings["//toolchain:camlheaders"]

    # build_host  = settings["//command_line_option:host_platform"]
    # extra_execution_platforms = settings["//command_line_option:extra_execution_platforms"]

    # target_host = settings["//command_line_option:platforms"]

    # stage = int(settings["//config/stage"])

    if debug:
        # print("//config/stage: %s" % stage)
        print("//config/target/executor: %s" % settings[
            "//config/target/executor"])
        print("//config/target/emitter:  %s" % settings[
            "//config/target/emitter"])

        print("//toolchain:compiler  %s" % compiler)
        # print("//toolchain:lexer  %s" % lexer)
        print("//toolchain:runtime  %s" % runtime)
        # print("//toolchain:camlheaders  %s" % camlheaders)

        # print("//toolhchain:runtime:     %s" % target_runtime)
        # print("attr.target_executor: %s" % attr.target_executor)
        # print("//command_line_option:host_platform: %s" % build_host)
        # print("//command_line_option:extra_execution_platforms: %s" % extra_execution_platforms)
        # print("//command_line_option:platforms: %s" % target_host)

    host_compilation_mode = "opt"
    compilation_mode = "opt"
    # camlheaders = "//config/camlheaders"

    #remember config_executor is the target, so it determines the
    #emitter of the build host
    if config_executor in ["boot", "baseline", "vm"]:
        ## vm emitter
        compiler = "@baseline//bin:ocamlc.opt"
        runtime = "@baseline//lib:libasmrun.a"
    else:
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime = "@baseline//lib:libasmrun.a"

    if debug:
        print("setting compiler: %s" % compiler)
        print("setting emitter:  %s" % config_emitter)
        print("setting runtime:   %s" % runtime)
        # print("setting camlheaders:   %s" % camlheaders)

    return {
        "//toolchain:compiler": compiler,
        "//toolchain:runtime"  : runtime,
        # "//toolchain:camlheaders"  : camlheaders,
    }

#######################
dev_tc_compiler_out_transition = transition(
    implementation = _dev_tc_compiler_out_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        # "//toolchain:camlheaders",

        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
    ],
    outputs = [
        "//toolchain:compiler",
        "//toolchain:runtime",

        # "//toolchain:camlheaders",
    ]
)
