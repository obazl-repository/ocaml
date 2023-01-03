load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

################################################################
## boot_ocamlc_import_in_transition: transition to const config, so
## the dependent ocamlrun is only built once.
def _boot_ocamlc_import_in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("TRANSITION: boot_ocamlc_import_in_transition")
        print("protocol: %s" % settings["//config/build/protocol"])
        print("compiler: %s" % settings["//toolchain:compiler"])

    ## compiler should always be boot:ocamlc.boot

    return {
        "//config/build/protocol": "preboot", # FIXME
        "//toolchain:compiler"   : "//boot:ocamlc"
    }

###################################
boot_ocamlc_import_in_transition = transition(
    implementation = _boot_ocamlc_import_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//toolchain:compiler"
    ],
    outputs = [
        "//config/build/protocol",
        "//toolchain:compiler"
    ]
)

################################################################
################################################################
def _boot_ocamlc_import_impl(ctx):
    ocamlc = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(output = ocamlc,
                        target_file = ctx.file._ocamlc)
    runfiles = ctx.runfiles(
        files = [ctx.file._ocamlrun]
    )
    defaultInfo = DefaultInfo(
        executable = ocamlc,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
boot_ocamlc_import = rule(
    implementation = _boot_ocamlc_import_impl,
    doc = "Imports the precompiled ocamlc, uses it to build stdlib and adds to runfiles",
    attrs = dict(
        _ocamlc = attr.label(
            allow_single_file = True,
            default = ":ocamlc"
        ),
        _ocamlrun = attr.label(
            allow_single_file = True,
            default = "//runtime:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    cfg = boot_ocamlc_import_in_transition
)

################################################################
def _coldstart_in_transition_impl(settings, attr):
    debug = True

    if debug:
        print("TRANSITION: coldstart_in_transition")
        print("protocol: %s" % settings["//config/build/protocol"])
        print("compiler: %s" % settings["//toolchain:compiler"])
        print("config_executor: %s" % settings["//config/target/executor"])
        print("config_emitter: %s" % settings["//config/target/emitter"])
        print("setting protocol to: boot")

        # if settings["//config/target/executor"] == "boot":
    #     executor = "sys"
    #     emitter  = "vm"
    # else:
    #     executor = settings["//config/target/executor"]
    #     emitter  = settings["//config/target/emitter"]

    return {
        "//config/build/protocol": "boot",
        # "//config/target/executor": executor,
        # "//config/target/emitter" : emitter
    }

###################################
_coldstart_in_transition = transition(
    implementation = _coldstart_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler"
    ],
    outputs = [
        "//config/build/protocol",
        # "//config/target/executor",
        # "//config/target/emitter"
    ]
)

########################
def _boot_coldstart_impl(ctx):

    runner = ctx.actions.declare_file("coldstart.sh")
    ctx.actions.symlink(output = runner,
                        target_file = ctx.file.runner)

    rfs = []

    ## we need to pass //config/target/executor, //config/target/emitter
    ## as args to coldstart.sh. We cannot set the 'args' attr here,
    ## so we write them to files and pass them in runfiles.
    ## the shell script reads them to discover what is being built
    ## and needs to be copied to .baseline/bin.

    executor = ctx.actions.declare_file("executor")
    ctx.actions.write(
        output  = executor,
        content = ctx.attr._target_executor[BuildSettingInfo].value
    )
    emitter = ctx.actions.declare_file("emitter")
    ctx.actions.write(
        output  = emitter,
        content = ctx.attr._target_emitter[BuildSettingInfo].value
    )
    rfs.append(depset(direct = [executor, emitter]))

    for d in ctx.attr.data:
        # print("DATUM: %s" % d)
        rfs.append(d.files)
        rfs.append(d[DefaultInfo].default_runfiles.files)

    # rfs.append(ctx.attr.lexer[DefaultInfo].files)
    # rfs.append(ctx.attr.lexer[DefaultInfo].default_runfiles.files)
    # for f in ctx.files.runtimes:
    #     # print("RUNTIME: %s" % d)
    #     rfs.append(f)

    runfiles = ctx.runfiles(
        files = ctx.files.runtimes,
        transitive_files = depset(transitive=rfs)
        # files = ctx.files.data + ctx.files.deps
    )

    defaultInfo = DefaultInfo(
        executable = runner,
        runfiles   = runfiles
    )

    return defaultInfo

#####################
boot_coldstart = rule(
    implementation = _boot_coldstart_impl,

    doc = "Builds boot toolchain and installs in .bootstrap/",

    attrs = dict(
        runner = attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "//boot:coldstart.sh",
        ),
        compilers = attr.label_list(
            allow_files = True
        ),
        data = attr.label_list(
            allow_files = True
        ),
        # lexer = attr.label(
        #     allow_single_file = True,
        #     default = "//lex:ocamllex",
        # ),
        deps = attr.label_list(
            allow_files = True
        ),

        runtimes = attr.label_list(
            allow_files = True,
            doc = "libcamlrun.a, libsmrun.a"
        ),

        _target_executor = attr.label(default = "//config/target/executor"),

        _target_emitter = attr.label(default = "//config/target/emitter"),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

    ),
    cfg = _coldstart_in_transition,
    executable = True,
    # toolchains = ["//toolchain/type:ocaml"],
)

###############################
# def boot_coldstart(**kwargs):
#   if "args" not in kwargs:
#       kwargs["args"] = ["a", "b", "c"]
#   _boot_coldstart(**kwargs)

################################################################

def _boot_setup_impl(ctx):

    runner = ctx.actions.declare_file("setup.sh")
    ctx.actions.symlink(output = runner,
                        target_file = ctx.file.runner)

    rfs = []

    for d in ctx.attr.data:
        # print("DATUM: %s" % d)
        rfs.append(d.files)
        rfs.append(d[DefaultInfo].default_runfiles.files)

    # for f in ctx.files.runtimes:
    #     # print("RUNTIME: %s" % d)
    #     rfs.append(f)

    runfiles = ctx.runfiles(
        # files = ctx.files.runtimes,
        transitive_files = depset(transitive=rfs)
    )

    defaultInfo = DefaultInfo(
        executable = runner,
        runfiles   = runfiles
    )

    return defaultInfo

#####################
boot_setup = rule(
    implementation = _boot_setup_impl,

    doc = "Prebuilds CC tools",

    attrs = dict(
        runner = attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "//boot:coldstart.sh",
        ),
        data = attr.label_list(
            allow_files = True
        ),
    ),
    executable = True,
)
