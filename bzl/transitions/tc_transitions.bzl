load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load(":transitions.bzl",
     "tc_boot_in_transition_impl",
     "tc_compiler_out_transition_impl",
     "tc_lexer_out_transition_impl",
     "tc_runtime_out_transition_impl",
     "tc_mustache_transition_impl",
     "reset_config_transition_impl")

#####################################################
def _tc_compiler_out_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_compiler_out_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    return tc_compiler_out_transition_impl(settings, attr, debug)

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
        "//toolchain:runtime",

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

        # "//command_line_option:host_compilation_mode",
        # "//command_line_option:compilation_mode",

        # "//toolchain/target/executor",
        # "//toolchain/target/emitter",

        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",
    ]
)

#####################################################
def _tc_lexer_out_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_lexer_out_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    return tc_lexer_out_transition_impl(settings, attr, debug)

#######################
tc_lexer_out_transition = transition(
    implementation = _tc_lexer_out_transition_impl,
    inputs = [
        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain/target/executor",
        "//toolchain/target/emitter",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",
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
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
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
        # "//command_line_option:host_platform",
        # "//command_line_option:extra_execution_platforms",
        # "//command_line_option:platforms",
        # "//config/target/runtime",

        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain/target/executor",
        "//toolchain/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",
    ]
)

#####################################################
def _tc_boot_in_transition_impl(settings, attr):

    ## called for tc.compiler and tc.lexer
    ## so we should see this twice per config

    debug = True

    if debug:
        print("ENTRY: tc_boot_in_transition")
        print("tc name: %s" % attr.name)
        # print("attrs: %s" % attr)

    return tc_boot_in_transition_impl(settings, attr, debug)

#######################
tc_boot_in_transition = transition(
    implementation = _tc_boot_in_transition_impl,

    inputs = [
        # "//command_line_option:host_platform",
        # "//command_line_option:extra_execution_platforms",
        # "//command_line_option:platforms",
        # "//config/target/runtime",

        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",

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

        # "//command_line_option:host_compilation_mode",
        # "//command_line_option:compilation_mode",

        # "//toolchain/target/executor",
        # "//toolchain/target/emitter",

        "//config/target/executor",
        "//config/target/emitter",

        "//toolchain:compiler",
        "//toolchain:lexer",
        "//toolchain:runtime",
    ]
)

#######################
# reset_config_transition = transition(
#     implementation = reset_config_transition_impl,
#     inputs = ["//config:dev"],
#     outputs = [
#         # "//toolchain/target/executor",
#         # "//toolchain/target/emitter",

#         "//config/target/executor",
#         "//config/target/emitter",

#         "//toolchain:compiler",
#         "//toolchain:lexer",
#     ]
# )

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

