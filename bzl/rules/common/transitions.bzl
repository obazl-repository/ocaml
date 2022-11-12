load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

## exports: boot_toolchain_adapter (rule). includes stuff only
## used during bootstrapping, e.g. primitives.

##################################################
def _toolchain_in_transition_impl(settings, attr):
    # print("toolchain_in_transition_impl")

    ## trying to make sure ocamlrun is only built once

    return {
        "//bzl/toolchain:ocamlrun" : "//boot/bin:ocamlrun"
    }

#######################
toolchain_in_transition = transition(
    implementation = _toolchain_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlrun"
    ],
    outputs = [
        "//bzl/toolchain:ocamlrun"
    ]
)

###################################################
###################################################
def _compiler_in_transition_impl(settings, attr):
    print("compiler_in_transition")

    if hasattr(attr, "stage"):
        print("  stage: %s" % attr.stage)
        print("  bzl stage: %s" % settings["//bzl:stage"])
        stage = attr.stage
        if stage == "boot":
            # no change
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
        elif stage == "baseline":
            stage = "boot"
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
        elif stage == "dev":
            stage = "baseline"
            compiler = "//boot/bin:ocamlc.byte"
            lexer = "//boot/bin:ocamllex.byte"
        else:
            print("UNHANDLED COMPILER STAGE: %s" % stage)
            stage    = settings["//bzl:stage"]
            compiler = settings["//boot/toolchain:compiler"]
            stdlib   = settings["//boot/toolchain:stdlib"]
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
        "//boot/toolchain:lexer"
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

    if hasattr(attr, "stage"):
        print("  stage: %s" % attr.stage)
        print("  bzl stage: %s" % settings["//bzl:stage"])
        stage = attr.stage
        if stage == "boot":
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
            stdlib = "//stdlib" # //boot:stdlib
        elif stage == "baseline":
            stage = "boot"
            compiler = "//boot:ocamlc.boot"
            lexer = "//boot:ocamllex.boot"
            stdlib = "//boot:stdlib"
        elif stage == "dev":
            stage = "baseline"
            compiler = "//boot/bin:ocamlc.byte"
            lexer = "//boot/bin:ocamllex.byte"
            stdlib = "//boot/bin:stdlib"
        else:
            print("UNHANDLED STDLIB STAGE: %s" % stage)
            stage    = settings["//bzl:stage"]
            compiler = settings["//boot/toolchain:compiler"]
            stdlib   = settings["//boot/toolchain:stdlib"]
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

    # if settings["//platforms/xtarget"] == "sys":

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
    # print("  xtarget: %s" % settings["//platforms/xtarget"])

    # if settings["//platforms/xtarget"] == "sys":

    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    return {}
    #     "//command_line_option:host_platform" : "//platforms/build:boot",
    #     "//command_line_option:platforms" : "//platforms/target:boot"
    # }

exe_deps_out_transition = transition(
    implementation = _exe_deps_out_transition_impl,
    inputs = [
        # "//platforms/xtarget",
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ]
)


# #####################################################
# def _boot_compiler_out_transition_impl(settings, attr):
#     print("boot_compiler_out_transition")
#     # print("  stage: %s" % settings["//bzl:stage"])

#     # print("//bzl/toolchain:ocamlc: %s" %
#     #       settings["//bzl/toolchain:ocamlc"])

#     return {
#         "//bzl:stage": 1,
#         "//bzl/toolchain:ocamlc" : "//boot:ocamlc"
#     }

# #######################
# boot_compiler_out_transition = transition(
#     implementation = _boot_compiler_out_transition_impl,
#     inputs = [
#         "//bzl:stage",
#         "//bzl/toolchain:ocamlc"
#     ],
#     outputs = [
#         "//bzl:stage",
#         "//bzl/toolchain:ocamlc"
#     ]
# )

