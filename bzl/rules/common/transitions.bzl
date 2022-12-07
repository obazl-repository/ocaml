load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

#####################################################
## reset_config_transition
# reset stage to 0 (_boot) so runtime is only built once

def _reset_config_transition_impl(settings, attr):
    print("reset_config_transition: %s" % attr.name)
    return {
        # "//toolchain/target/executor": "boot",
        # "//toolchain/target/emitter" : "boot",

        "//config/target/executor": "boot",
        "//config/target/emitter" : "boot",

        "//toolchain:compiler" : "//boot:ocamlc.boot",
        "//toolchain:lexer"    : "//boot:ocamllex.boot",
    }

#######################
reset_config_transition = transition(
    implementation = _reset_config_transition_impl,
    inputs = [],
    outputs = [
        # "//toolchain/target/executor",
        # "//toolchain/target/emitter",

        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
    ]
)

#####################################################
def _tc_compiler_out_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_compiler_out_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    ## we use the CLI string flags in //config/...
    ## to set string settings in //toolchain/...
    target_executor = settings["//toolchain/target/executor"]
    target_emitter  = settings["//toolchain/target/emitter"]
    config_executor = settings["//config/target/executor"]
    config_emitter  = settings["//config/target/emitter"]
    # target_runtime  = settings["//toolchain:runtime"]

    compiler = settings["//toolchain:compiler"]
    lexer = settings["//toolchain:lexer"]

    # build_host  = settings["//command_line_option:host_platform"]
    # extra_execution_platforms = settings["//command_line_option:extra_execution_platforms"]

    # target_host = settings["//command_line_option:platforms"]

    # stage = int(settings["//config/stage"])

    if debug:
        # print("//config/stage: %s" % stage)
        print("//toolchain/target/executor: %s" % settings[
            "//toolchain/target/executor"])
        print("//toolchain/target/emitter:  %s" % settings[
            "//toolchain/target/emitter"])
        print("//config/target/executor: %s" % settings[
            "//config/target/executor"])
        print("//config/target/emitter:  %s" % settings[
            "//config/target/emitter"])

        print("//toolchain:compiler:  %s" % settings["//toolchain:compiler"])
        print("//toolchain:lexer:  %s" % settings["//toolchain:lexer"])

        # print("//toolhchain:runtime:     %s" % target_runtime)
        # print("attr.target_executor: %s" % attr.target_executor)
        # print("//command_line_option:host_platform: %s" % build_host)
        # print("//command_line_option:extra_execution_platforms: %s" % extra_execution_platforms)
        # print("//command_line_option:platforms: %s" % target_host)


    ## avoid rebuilding _boot/ocamlc.byte: ??

    host_compilation_mode = "opt"
    compilation_mode = "opt"
    # runtime  = "//runtime:ocamlrun"

    ## initial config: config settings passed on cli, toolchain
    ## configs default to unspecified

    # if target_executor == "unspecified":
    #     print("INITIAL TRANSITION")
    #     target_executor = config_executor
    #     target_emitter = config_emitter

    if (config_executor == "boot"): #and config_emitter == "boot"):
        print("BOOT TRANSITION")
        compilation_mode = "opt"
        config_executor = "baseline"
        config_emitter  = "baseline"

        if (compiler == "//boot:ocamlc.boot" and
            lexer    == "//boot:ocamllex.boot"):
            compiler = "//boot:ocamlc.boot"
            lexer    = "//boot:ocamllex.boot"
            # return{}
        else:
            compiler = "//boot:ocamlc.boot"
            lexer    = "//boot:ocamllex.boot"

    elif (config_executor == "baseline"):
        compiler = "//boot:ocamlc.boot"
        lexer    = "//boot:ocamllex.boot"
    #     fail("bad config_emitter: %s" % config_emitter)

    elif (config_executor == "vm" and config_emitter == "vm"):
        print("VM-VM TRANSITION")
        config_executor = "baseline"
        config_emitter  = "baseline"
        ## these just prevent circular dep?
        ## need to set before recurring, otherwise we get a dep cycle
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"
        # compiler = "//boot:ocamlc.boot"
        # lexer    = "//boot:ocamllex.boot"

    elif (config_executor == "vm" and config_emitter == "sys"):
        print("VM-SYS transition")
        config_executor = "vm"
        config_emitter = "vm"
        # target_executor = "boot"
        # target_emitter = "boot"
        # target_executor = "vm"
        # target_emitter = "vm"
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"

    elif (config_executor == "sys" and config_emitter == "sys"):
        print("SYS-SYS transition")
        config_executor = "vm"
        config_emitter  = "sys"
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"

    elif (config_executor == "sys" and config_emitter == "vm"):
        print("SYS-VM transition")
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlcc"
        lexer    = "//lex:ocamllex"

    else:
        fail("xxxxxxxxxxxxxxxx %s" % config_executor)

    if debug:
        # print("setting //toolchain/target/executor: %s" % target_executor)
        # print("setting //toolchain/target/emitter: %s" % target_emitter)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter: %s" % config_emitter)
        print("setting //toolchain:compiler %s" % compiler)
        print("setting //toolchain:lexer %s" % lexer)

    return {
        "//command_line_option:host_compilation_mode": "opt",
        "//command_line_option:compilation_mode": "opt",

        # "//toolchain/target/executor": target_executor,
        # "//toolchain/target/emitter" : target_emitter,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,

        "//toolchain:compiler": compiler,
        "//toolchain:lexer"   : lexer,
    }

#######################
tc_compiler_out_transition = transition(
    implementation = _tc_compiler_out_transition_impl,
    inputs = [
        # "//command_line_option:host_platform",
        # "//command_line_option:extra_execution_platforms",
        # "//command_line_option:platforms",
        # "//config/target/runtime",

        "//toolchain:compiler",
        "//toolchain:lexer",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain/target/executor",
        "//toolchain/target/emitter",

        # "//config/stage",
        # "//toolchain:compiler",
        # "//toolchain:lexer"
        # "//toolchain:runtime"
    ],
    outputs = [
        # "//command_line_option:host_platform",
        # "//command_line_option:extra_execution_platforms",
        # "//command_line_option:platforms",
        # "//config/stage",

        "//command_line_option:host_compilation_mode",
        "//command_line_option:compilation_mode",

        # "//toolchain/target/executor",
        # "//toolchain/target/emitter",

        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
    ]
)

##################################################
# def _toolchain_in_transition_impl(settings, attr):
#     # sets the compiler
#     print("toolchain_in_transition_impl")

#     # set platforms
#     build_host  = settings["//command_line_option:host_platform"]
#     print("  host_platform: %s" % build_host)

#     target_host = settings["//command_line_option:platforms"]
#     print("  platforms: %s" % target_host)

#     # if hasattr(attr, "stage"):
#     #     print("  stage: %s" % attr.stage)
#     #     print("  bzl stage: %s" % settings["//config/stage"])
#     stage = settings["//config/stage"]
#     print("  stage: %s" % stage)

#     if stage == 0:
#         # no change
#         return {}

#     stage = stage

#     if stage == 0:  # boot
#         compiler = "//boot:ocamlc.byte"
#         lexer = "//boot:ocamllex.boot"
#         # lexer = "//boot:ocamllex.boot"
#     elif stage == 1: # dev built by baseline tc
#         compiler = "//boot/baseline:baseline" # ocamlc.byte"
#         lexer = "//boot/baseline:ocamllex.byte"
#     elif stage == 2:
#         compiler = "//dev/bin:ocamlc.byte"
#         lexer = "//dev/bin:ocamllex.byte"
#     else:
#         fail("UNHANDLED COMPILER STAGE: %s" % stage)
#     # else:
#     #     fail("compiler missing attr: stage")

#     return {
#         "//config/stage"              : stage,
#         "//toolchain:compiler": compiler,
#         "//toolchain:lexer"   : lexer
#     }

# #######################
# toolchain_in_transition = transition(
#     implementation = _toolchain_in_transition_impl,
#     inputs = [
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms",
#         "//config/stage",
#     ],
#     outputs = [
#         # "//command_line_option:host_platform",
#         # "//command_line_option:platforms"
#         "//config/stage",
#         "//toolchain:compiler",
#         "//toolchain:lexer",
#         # "//toolchain:stdlib"
#     ]
# )

###################################################
###################################################
# def _compiler_in_transition_impl(settings, attr):
#     print("compiler_in_transition")

#     build_host  = settings["//command_line_option:host_platform"]
#     print("  host_platform: %s" % build_host)

#     target_host = settings["//command_line_option:platforms"]
#     print("  platforms: %s" % target_host)

#     # target constraint predicates:
#     print("xxxx: %s" % "//platform/constraints/ocaml/emitter:sys_emitter?")


#     stage = settings["//config/stage"]
#     print("  stage: %s" % stage)

#     if stage == 0:
#         # no change
#         return {}

#     # stage = stage

#     # if stage == 0:  # boot
#     #     compiler = "//boot:ocamlc.byte"
#     #     lexer = "//boot:ocamllex.boot"
#     #     # lexer = "//boot:ocamllex.boot"
#     # elif stage == 1: # dev built by baseline tc
#     #     compiler = "//bin:ocamlcc" # ocamlc.byte"
#     #     lexer = "//boot/baseline:lexer"
#     # elif stage == 2:
#     #     compiler = "//bin:ocamlcc" # ocamlc.byte"
#     #     lexer = "//lex:ocamllex"
#     #     # compiler = "//dev/bin:ocamlc.dev"
#     #     # lexer = "//dev/bin:ocamllex.byte"
#     # else:
#     #     fail("UNHANDLED COMPILER STAGE: %s" % stage)

#     # if hasattr(attr, "stage"):
#     #     print("  stage: %s" % attr.stage)
#     #     print("  bzl stage: %s" % settings["//config/stage"])
#     #     _stage = attr.stage
#     #     if _stage == "boot":
#     #         # no change
#     #         stage    = 0
#     #         compiler = "//boot:ocamlc.boot"
#     #         lexer = "//boot:ocamllex.boot"
#     #     elif _stage == "baseline":
#     #         stage    = 0  # baseline built by boot tc
#     #         # stage = "boot"
#     #         compiler = "//boot:ocamlc.byte"
#     #         lexer = "//boot:ocamllex.byte"
#     #         # lexer = "//boot:ocamllex.boot"
#     #     elif _stage == "dev":
#     #         stage = 1  # dev built by baseline tc
#     #         compiler = "//boot/baseline:ocamlc.byte"
#     #         lexer = "//boot/baseline:ocamllex.byte"
#     #     elif _stage == "prod":
#     #         stage = 2  # prod built by dev tc
#     #         compiler = "//dev/bin:ocamlc.byte"
#     #         lexer = "//dev/bin:ocamllex.byte"
#     #     else:
#     #         fail("UNHANDLED COMPILER STAGE: %s" % stage)
#     # else:
#     #     fail("compiler missing attr: stage")

#     return {}
#     #     "//config/stage"              : stage,
#     #     "//toolchain:compiler": compiler,
#     #     "//toolchain:lexer"   : lexer
#     # }

# compiler_in_transition = transition(
#     implementation = _compiler_in_transition_impl,
#     inputs  = [
#         "//config/stage",
#         "//toolchain:compiler",
#         "//toolchain:lexer",
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms"
#     ],
#     outputs = [
#         # "//config/stage",
#         # "//toolchain:compiler",
#         # "//toolchain:lexer"
#     ]
# )

# ###################################################
# ###################################################
# def _stdlib_in_transition_impl(settings, attr):
#     print("stdlib_in_transition")

#     ## same code as compiler_in_transition?
#     if hasattr(attr, "stage"):
#         print("  stage: %s" % attr.stage)
#         print("  bzl stage: %s" % settings["//config/stage"])
#         _stage = attr.stage
#         if _stage == "boot":
#             stage    = 0
#             compiler = "//boot:ocamlc.boot"
#             lexer = "//boot:ocamllex.boot"
#             stdlib = "//stdlib" # //boot:stdlib
#         elif stage == "baseline":
#             stage    = 1
#             compiler = "//boot:ocamlc.boot"
#             lexer = "//boot:ocamllex.boot"
#             stdlib = "//boot:stdlib"
#         elif stage == "dev":
#             stage    = 1
#             compiler = "//boot/baseline:ocamlc.byte"
#             lexer = "//boot/baseline:ocamllex.byte"
#             stdlib = "//boot/baseline:stdlib"
#         else:
#             fail("UNHANDLED STDLIB STAGE: %s" % stage)
#     else:
#         fail("stdlib missing attr: stage")

#     return {
#         "//config/stage"              : stage,
#         "//toolchain:compiler": compiler,
#         "//toolchain:lexer"   : lexer,
#         "//toolchain:stdlib"  : stdlib
#     }

# ##################################
# stdlib_in_transition = transition(
#     ## we need this in case stdlib is built directly. if it's built as
#     ## a compiler dep, then the transition has already been made by
#     ## the compiler target.
#     implementation = _stdlib_in_transition_impl,
#     inputs  = [
#         "//config/stage",
#         "//toolchain:compiler",
#         "//toolchain:lexer",
#         "//toolchain:stdlib"
#     ],
#     outputs = [
#         "//config/stage",
#         "//toolchain:compiler",
#         "//toolchain:lexer",
#         "//toolchain:stdlib"
#     ]
# )

# ################################################################
# def _compile_deps_out_transition_impl(settings, attr):
#     # print("compile_deps_out_transition: %s" % attr.name)
#     # for m in dir(attr):
#     #     print("item: %s" % m)

#     if attr.name in settings["//config:manifest"]:
#         manifest = settings["//config:manifest"]
#     else:
#         manifest = []

#     return {
#             "//config:manifest": manifest
#     }

# compile_deps_out_transition = transition(
#     implementation = _compile_deps_out_transition_impl,
#     inputs = [
#         "//config:manifest"
#     ],
#     outputs = [
#         "//config:manifest"
#     ]
# )

# ################################################################
# def _manifest_out_transition_impl(settings, attr):
#     # print("manifest_out_transition")

#     # print("settings: %s" % settings)

#     # for d in dir(attr):
#     #     print("attr: %s" % d)

#     # for m in attr.manifest:
#     #     print("item: %s" % m)

#     # if settings["//platform/xtarget"] == "sys":

#     # print("//bzl/toolchain:ocamlc: %s" %
#     #       settings["//bzl/toolchain:ocamlc"])

#     manifest = [str(f.package) + "/" + str(f.name) for f in attr.manifest]
#     manifest.append(attr.name)

#     return {
#             "//config:manifest": manifest
#     }

# manifest_out_transition = transition(
#     implementation = _manifest_out_transition_impl,
#     inputs = [
#         "//config:manifest"
#     ],
#     outputs = [
#         "//config:manifest"
#     ]
# )

# ################################################################
# def _exe_deps_out_transition_impl(settings, attr):
#     print("exe_deps_out_transition")
#     # print("  xtarget: %s" % settings["//platform/xtarget"])

#     # if settings["//platform/xtarget"] == "sys":

#     # print("//bzl/toolchain:ocamlc: %s" %
#     #       settings["//bzl/toolchain:ocamlc"])

#     return {}
#     #     "//command_line_option:host_platform" : "//platform/build:boot",
#     #     "//command_line_option:platforms" : "//platform/target:boot"
#     # }

# exe_deps_out_transition = transition(
#     implementation = _exe_deps_out_transition_impl,
#     inputs = [
#         # "//platform/xtarget",
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms"
#     ],
#     outputs = [
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms"
#     ]
# )

# #####################################################
# def _emitter_out_transition_impl(settings, attr):

#     print("emitter_out_transition")

#     build_host  = settings["//command_line_option:host_platform"]
#     print("  host_platform: %s" % build_host)

#     target_host = settings["//command_line_option:platforms"]
#     print("  platforms: %s" % target_host)

#     return {
#         "//config/build/emitter": "arm64",
#         "//config/target/emitter": "amd64"
#     }

# #######################
# emitter_out_transition = transition(
#     implementation = _emitter_out_transition_impl,
#     inputs = [
#         "//command_line_option:host_platform",
#         "//command_line_option:platforms"
#     ],
#     outputs = [
#         "//config/build/emitter",
#         "//config/target/emitter"
#     ]
# )

