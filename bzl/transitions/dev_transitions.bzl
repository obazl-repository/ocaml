load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

#####################################################
def _dev_tc_compiler_out_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: dev_tc_compiler_out_transition")
        print("bld tgt: %s" % attr.name)
        print("tc name: %s" % attr.name)
        print("test mode?: %s" % settings["//config:test"])

    if settings["//config:test"]:
        print("id txn ")
        return {}

    ## we use the CLI string flags in //config/...
    ## to set string settings in //toolchain/...

    config_executor = settings["//config/target/executor"]
    config_emitter  = settings["//config/target/emitter"]
    # target_runtime  = settings["//toolchain:runtime"]

    compiler = settings["//toolchain/dev:compiler"]
    lexer = settings["//toolchain/dev:lexer"]
    runtime = settings["//toolchain/dev:runtime"]
    camlheaders = settings["//toolchain/dev:camlheaders"]

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

        print("//toolchain/dev:compiler  %s" % compiler)
        print("//toolchain/dev:lexer  %s" % lexer)
        print("//toolchain/dev:runtime  %s" % runtime)
        print("//toolchain/dev:camlheaders  %s" % camlheaders)

        # print("//toolhchain:runtime:     %s" % target_runtime)
        # print("attr.target_executor: %s" % attr.target_executor)
        # print("//command_line_option:host_platform: %s" % build_host)
        # print("//command_line_option:extra_execution_platforms: %s" % extra_execution_platforms)
        # print("//command_line_option:platforms: %s" % target_host)

    host_compilation_mode = "opt"
    compilation_mode = "opt"
    camlheaders = "//config/camlheaders"

    #remember config_executor is the target, so it determines the
    #emitter of the build host
    if config_executor in ["boot", "vm"]:
        ## vm emitter
        compiler = "@baseline//bin:ocamlc.opt"
        runtime = "@baseline//lib:libcamlrun.a"
    else:
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime = "@baseline//lib:libasmrun.a"

    if debug:
        print("setting compiler: %s" % compiler)
        print("setting emitter:  %s" % config_emitter)
        print("setting runtime:   %s" % runtime)
        print("setting camlheaders:   %s" % camlheaders)

    return {
        "//toolchain/dev:compiler": compiler,
        "//toolchain/dev:runtime"  : runtime,
        "//toolchain/dev:camlheaders"  : camlheaders,

    }

#######################
dev_tc_compiler_out_transition = transition(
    implementation = _dev_tc_compiler_out_transition_impl,
    inputs = [
        "//config:test",
        "//config/target/executor",
        "//config/target/emitter",
        # "//toolchain/dev:camlheaders",

        "//toolchain/dev:compiler",
        "//toolchain/dev:lexer",
        "//toolchain/dev:runtime",
    ],
    outputs = [
        "//toolchain/dev:compiler",
        "//toolchain/dev:runtime",

        "//toolchain/dev:camlheaders",
    ]
)
