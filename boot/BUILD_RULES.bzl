load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

################################################################
def _ocamlc_boot_in_transition_impl(settings, attr):

    print("OCAMLC_BOOT TG")

    return {
        "//config/build/protocol": "preboot",
        "//toolchain:compiler"   : "//boot:ocamlc"
    }

###################################
ocamlc_boot_in_transition = transition(
    implementation = _ocamlc_boot_in_transition_impl,
    inputs = [],
    outputs = [
        "//config/build/protocol",
        "//toolchain:compiler"
    ]
)

################################################################
def _ocamlc_boot_impl(ctx):

    tool = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.symlink(output = tool,
                        target_file = ctx.file.tool)

    runfiles = ctx.runfiles(
        files = [ctx.file._stdlib]
    )

    defaultInfo = DefaultInfo(
        executable = tool,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
ocamlc_boot = rule(
    implementation = _ocamlc_boot_impl,

    doc = "Imports the precompiled ocamlc, uses it to build stdlib and adds to runfiles",

    attrs = dict(
        tool = attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        # stdlib is a runtime dep of the linker, so we need to build
        # it and add it runfiles.
        _stdlib = attr.label(
            doc = "Stdlib archive", ## (not stdlib.cmx?a")
            default = "//stdlib", # archive, not resolver
            allow_single_file = True, # won't work with boot_library
            executable = False,
            # cfg = "exec"
            # cfg = ocamlc_boot_in_transition
        ),

        # std_exit = attr.label(
        #     doc = "Module linked last in every executable.",
        #     default = "//stdlib:Std_exit",
        #     allow_single_file = True,
        #     # cfg = exe_deps_out_transition,
        # ),

        ## and ditto for camlheaders
        # _camlheaders = attr.label_list(
        #     allow_files = True,
        #     default = ["//config/camlheaders"]
        # ),

        # _ocamlrun = attr.label(
        #     allow_single_file = True,
        #     default = "//runtime:ocamlrun",
        #     executable = True,
        #     # cfg = "exec"
        #     cfg = reset_cc_config_transition
        # ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    cfg = ocamlc_boot_in_transition
)

################################################################
def _coldstart_transition_impl(settings, attr):

    # if settings["//config/target/executor"] == "boot":
    #     executor = "sys"
    #     emitter  = "vm"
    # else:
    #     executor = settings["//config/target/executor"]
    #     emitter  = settings["//config/target/emitter"]

    return {
        "//config/build/protocol": "baseline",
        # "//config/target/executor": executor,
        # "//config/target/emitter" : emitter
    }

###################################
_coldstart_transition = transition(
    implementation = _coldstart_transition_impl,
    inputs = [
        # "//config/build/protocol",
        # "//config/target/executor",
        # "//config/target/emitter"
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
    cfg = _coldstart_transition,
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
