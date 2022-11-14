load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

## exports: boot_toolchain_adapter (rule). includes stuff only
## used during bootstrapping, e.g. primitives.

# ##################################################
# def _toolchain_in_transition_impl(settings, attr):
#     # print("toolchain_in_transition_impl")

#     ## trying to make sure ocamlrun is only built once

#     return {
#         "//bzl/toolchain:ocamlrun" : "//boot/baseline:ocamlrun"
#     }

# #######################
# toolchain_in_transition = transition(
#     implementation = _toolchain_in_transition_impl,
#     inputs = [
#         "//bzl/toolchain:ocamlrun"
#     ],
#     outputs = [
#         "//bzl/toolchain:ocamlrun"
#     ]
# )

###################################################
###################################################
def _compiler_in_transition_impl(settings, attr):
    print("compiler_in_transition")

    build_host  = settings["//command_line_option:host_platform"]
    print("  host_platform: %s" % build_host)

    target_host = settings["//command_line_option:platforms"]
    print("  platforms: %s" % target_host)


    if hasattr(attr, "stage"):
        print("  stage: %s" % attr.stage)
        print("  bzl stage: %s" % settings["//bzl:stage"])
        _stage = attr.stage
        if _stage == "boot":
            # no change
            stage    = 0
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
        elif _stage == "baseline":
            stage    = 0  # baseline built by boot tc
            # stage = "boot"
            compiler = "//boot:ocamlc.byte"
            lexer = "//boot:ocamllex.byte"
            # lexer = "//boot:ocamllex.boot"
        elif _stage == "dev":
            stage = 1  # dev built by baseline tc
            compiler = "//boot/baseline:ocamlc.byte"
            lexer = "//boot/baseline:ocamllex.byte"
        elif _stage == "prod":
            stage = 2  # prod built by dev tc
            compiler = "//dev/bin:ocamlc.byte"
            lexer = "//dev/bin:ocamllex.byte"
        else:
            fail("UNHANDLED COMPILER STAGE: %s" % stage)
    else:
        fail("compiler missing attr: stage")

    return {
        "//bzl:stage"              : stage,
        "//boot/toolchain:compiler": compiler,
        "//boot/toolchain:lexer"   : lexer
    }

compiler_in_transition = transition(
    implementation = _compiler_in_transition_impl,
    inputs  = [
        "//bzl:stage",
        "//boot/toolchain:compiler",
        "//boot/toolchain:lexer",
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//bzl:stage",
        "//boot/toolchain:compiler",
        "//boot/toolchain:lexer"
    ]
)

###################################################
###################################################
def _stdlib_in_transition_impl(settings, attr):
    print("stdlib_in_transition")

    ## same code as compiler_in_transition?
    if hasattr(attr, "stage"):
        print("  stage: %s" % attr.stage)
        print("  bzl stage: %s" % settings["//bzl:stage"])
        _stage = attr.stage
        if _stage == "boot":
            stage    = 0
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
            stdlib = "//stdlib" # //boot:stdlib
        elif stage == "baseline":
            stage    = 1
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
            stdlib = "//boot:stdlib"
        elif stage == "dev":
            stage    = 1
            compiler = "//boot/baseline:ocamlc.byte"
            lexer = "//boot/baseline:ocamllex.byte"
            stdlib = "//boot/baseline:stdlib"
        else:
            fail("UNHANDLED STDLIB STAGE: %s" % stage)
    else:
        fail("stdlib missing attr: stage")

    return {
        "//bzl:stage"              : stage,
        "//boot/toolchain:compiler": compiler,
        "//boot/toolchain:lexer"   : lexer,
        "//boot/toolchain:stdlib"  : stdlib
    }

##################################
stdlib_in_transition = transition(
    ## we need this in case stdlib is built directly. if it's built as
    ## a compiler dep, then the transition has already been made by
    ## the compiler target.
    implementation = _stdlib_in_transition_impl,
    inputs  = [
        "//bzl:stage",
        "//boot/toolchain:compiler",
        "//boot/toolchain:lexer",
        "//boot/toolchain:stdlib"
    ],
    outputs = [
        "//bzl:stage",
        "//boot/toolchain:compiler",
        "//boot/toolchain:lexer",
        "//boot/toolchain:stdlib"
    ]
)

################################################################
def _compile_deps_out_transition_impl(settings, attr):
    # print("compile_deps_out_transition: %s" % attr.name)
    # for m in dir(attr):
    #     print("item: %s" % m)

    if attr.name in settings["//config:manifest"]:
        manifest = settings["//config:manifest"]
    else:
        manifest = []

    return {
            "//config:manifest": manifest
    }

compile_deps_out_transition = transition(
    implementation = _compile_deps_out_transition_impl,
    inputs = [
        "//config:manifest"
    ],
    outputs = [
        "//config:manifest"
    ]
)

################################################################
def _manifest_out_transition_impl(settings, attr):
    # print("manifest_out_transition")

    # print("settings: %s" % settings)

    # for d in dir(attr):
    #     print("attr: %s" % d)

    # for m in attr.manifest:
    #     print("item: %s" % m)

    # if settings["//platform/xtarget"] == "sys":

    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    manifest = [str(f.package) + "/" + str(f.name) for f in attr.manifest]
    manifest.append(attr.name)

    return {
            "//config:manifest": manifest
    }

manifest_out_transition = transition(
    implementation = _manifest_out_transition_impl,
    inputs = [
        "//config:manifest"
    ],
    outputs = [
        "//config:manifest"
    ]
)

################################################################
def _exe_deps_out_transition_impl(settings, attr):
    print("exe_deps_out_transition")
    # print("  xtarget: %s" % settings["//platform/xtarget"])

    # if settings["//platform/xtarget"] == "sys":

    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    return {}
    #     "//command_line_option:host_platform" : "//platform/build:boot",
    #     "//command_line_option:platforms" : "//platform/target:boot"
    # }

exe_deps_out_transition = transition(
    implementation = _exe_deps_out_transition_impl,
    inputs = [
        # "//platform/xtarget",
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ]
)


#####################################################
def _compiler_out_transition_impl(settings, attr):

    print("compiler_out_transition")

    build_host  = settings["//command_line_option:host_platform"]
    target_host = settings["//command_line_option:platforms"]
    print("host_platform: %s" % build_host)

    print("platforms: %s" % target_host)

    return {} # nop
    #     "//command_line_option:host_platform" : build_host,
    #     "//command_line_option:platforms"     : target_host
    # }

#######################
compiler_out_transition = transition(
    implementation = _compiler_out_transition_impl,
    inputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ]
)

#####################################################
def _emitter_out_transition_impl(settings, attr):

    print("emitter_out_transition")

    build_host  = settings["//command_line_option:host_platform"]
    print("  host_platform: %s" % build_host)

    target_host = settings["//command_line_option:platforms"]
    print("  platforms: %s" % target_host)

    return {
        "//bzl:build_emitter": "arm64",
        "//bzl:target_emitter": "amd64"
    }

#######################
emitter_out_transition = transition(
    implementation = _emitter_out_transition_impl,
    inputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//bzl:build_emitter",
        "//bzl:target_emitter"
    ]
)

